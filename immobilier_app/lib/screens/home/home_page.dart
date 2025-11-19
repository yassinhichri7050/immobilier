import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/property_model.dart';
import '../../services/firestore_service.dart';
import '../../widgets/property_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late FirestoreService fs;

  @override
  void initState() {
    super.initState();
    fs = FirestoreService();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biens immobiliers'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          )
        ],
      ),
      // [AMÉLIORATION] Pull-to-refresh sur la liste
      body: RefreshIndicator(
        onRefresh: () async {
          // Trigger a refresh of the data
          setState(() {});
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // [AMÉLIORATION] Search bar améliorée
              Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/search'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!, width: 1),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: Colors.grey[600]),
                        const SizedBox(width: 12),
                        Text(
                          'Rechercher un bien...',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // [AMÉLIORATION] Section "Nouveaux biens"
              _buildSection(
                context,
                'Nouveaux biens',
                Icons.new_releases_outlined,
                fs.streamPropertiesRecent(limit: 5),
              ),

              // [AMÉLIORATION] Section "Promotions"
              _buildSection(
                context,
                'Promotions',
                Icons.local_offer_outlined,
                fs.streamPropertiesFeatured(),
              ),

              // [AMÉLIORATION] Section "Recommandés pour vous"
              _buildSection(
                context,
                'Recommandés pour vous',
                Icons.favorite_border,
                fs.streamPropertiesRecent(limit: 3),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // [AMÉLIORATION] Section avec icône, titre et empty state professionnel
  Widget _buildSection(
    BuildContext context,
    String title,
    IconData icon,
    Stream<QuerySnapshot> stream,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // [AMÉLIORATION] En-tête avec icône et bouton "Voir tout"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 24, color: Colors.red[700]),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/search'),
                icon: const Icon(Icons.arrow_forward, size: 18),
                label: const Text('Voir tout'),
              ),
            ],
          ),
        ),
        StreamBuilder<QuerySnapshot>(
          stream: stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // [AMÉLIORATION] Shimmer loading placeholder
              return _buildShimmerPlaceholder();
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              // [AMÉLIORATION] Empty state professionnel
              return _buildEmptyState(context, title);
            }

            final properties = snapshot.data!.docs
                .map((doc) => PropertyModel.fromMap(
                    doc.data() as Map<String, dynamic>, doc.id))
                .toList();

            return SizedBox(
              height: 300,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: properties.length,
                itemBuilder: (context, index) {
                  final prop = properties[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: SizedBox(
                      width: 240,
                      child: GestureDetector(
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/property_detail',
                          arguments: prop,
                        ),
                        child: PropertyCard(property: prop),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // [AMÉLIORATION] Shimmer loading placeholder
  Widget _buildShimmerPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                width: 240,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // [AMÉLIORATION] Empty state avec icône et bouton action
  Widget _buildEmptyState(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.home_work_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun bien trouvé',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Revenez plus tard ou modifiez vos filtres',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/search'),
              icon: const Icon(Icons.tune),
              label: const Text('Affiner la recherche'),
            ),
          ],
        ),
      ),
    );
  }
}
