import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../providers/user_provider.dart';
import '../../services/firestore_service.dart';
import '../../models/property_model.dart';
import '../../widgets/property_card.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final uid = auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil')),
      body: uid == null
          ? const Center(child: Text('Non connecté'))
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(24),
                    color: Colors.brown.withValues(alpha: 0.1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.brown,
                              child: Text(
                                (userProvider.user?.displayName ?? 'U')[0]
                                    .toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userProvider.user?.displayName ?? 'Utilisateur',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  userProvider.user?.email ?? '',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (userProvider.user?.phone != null &&
                            userProvider.user!.phone.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.phone, size: 16),
                              const SizedBox(width: 8),
                              Text(userProvider.user!.phone),
                            ],
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // My properties
                        const Text(
                          'Mes annonces',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirestoreService().streamPropertiesByUser(uid),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('Vous n\'avez aucune annonce'),
                              );
                            }

                            final properties = snapshot.data!.docs
                                .map((doc) => PropertyModel.fromMap(
                                    doc.data() as Map<String, dynamic>,
                                    doc.id))
                                .toList();

                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: properties.length,
                              itemBuilder: (context, index) {
                                final prop = properties[index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: GestureDetector(
                                    onTap: () => Navigator.pushNamed(
                                      context,
                                      '/property_detail',
                                      arguments: prop,
                                    ),
                                    child: PropertyCard(
                                      property: prop,
                                      horizontal: true,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        // Buttons
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, '/edit_profile'),
                            child: const Text('Modifier profil'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, '/change_password'),
                            child: const Text('Changer le mot de passe'),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () async {
                              await auth.signOut();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(
                                    context, '/login');
                              }
                            },
                            child: const Text(
                              'Se déconnecter',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pushNamed(context, '/about'),
                            child: const Text('À propos'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
