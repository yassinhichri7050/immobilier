import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/property_model.dart';
import '../../services/firestore_service.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  late PropertyModel property;
  bool _isFavorite = false;
  int _currentImageIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is PropertyModel) {
      property = args;
      _checkFavorite();
    }
  }

  void _checkFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final fs = FirestoreService();
    final isFav = await fs.isFavorite(uid, property.id);
    setState(() => _isFavorite = isFav);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Image carousel with hero animation
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: PageView.builder(
                onPageChanged: (index) =>
                    setState(() => _currentImageIndex = index),
                itemCount: property.images.isEmpty ? 1 : property.images.length,
                itemBuilder: (context, index) {
                  final imageUrl =
                      property.images.isEmpty ? '' : property.images[index];
                  return Hero(
                    tag: 'property_${property.id}',
                    child: Container(
                      color: Colors.grey[300],
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.home, size: 80)
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, st) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                    ),
                  );
                },
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    icon: Icon(
                      _isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorite ? Colors.red : Colors.grey,
                    ),
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('Veuillez vous connecter')),
                        );
                        return;
                      }
                      final fs = FirestoreService();
                      if (_isFavorite) {
                        await fs.removeFavorite(uid, property.id);
                      } else {
                        await fs.addFavorite(uid, property.id);
                      }
                      setState(() => _isFavorite = !_isFavorite);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Details
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and basic info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.title,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(property.location,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      Text(
                        '${property.price.toStringAsFixed(0)} €',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Key info
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(Icons.door_front_door, '${property.rooms} pièces'),
                      _buildInfoChip(Icons.square_foot, '${property.surface.toStringAsFixed(0)} m²'),
                      _buildInfoChip(Icons.home, property.type),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(property.description),
                  const SizedBox(height: 24),

                  // Contact button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/chat',
                              arguments: property.userId),
                      icon: const Icon(Icons.chat),
                      label: const Text('Contacter le vendeur'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.brown),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
