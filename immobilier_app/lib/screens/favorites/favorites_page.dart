import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/property_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/property_card.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mes favoris')),
        body: const Center(
          child: Text('Veuillez vous connecter'),
        ),
      );
    }

    final fs = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes favoris')),
      body: StreamBuilder<QuerySnapshot>(
        stream: fs.streamFavorites(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Aucun favori'),
                ],
              ),
            );
          }

          final favDocs = snapshot.data!.docs;

          return FutureBuilder<List<PropertyModel>>(
            future: Future.wait(
              favDocs.map((fav) async {
                final propId = fav['propertyId'];
                final propDoc = await fs.propertiesRef.doc(propId).get();
                return PropertyModel.fromMap(
                  propDoc.data() as Map<String, dynamic>,
                  propId,
                );
              }),
            ),
            builder: (context, propSnapshot) {
              if (propSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!propSnapshot.hasData || propSnapshot.data!.isEmpty) {
                return const Center(child: Text('Erreur lors du chargement'));
              }

              final properties = propSnapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/property_detail',
                          arguments: prop),
                      child: PropertyCard(property: prop, horizontal: true),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
