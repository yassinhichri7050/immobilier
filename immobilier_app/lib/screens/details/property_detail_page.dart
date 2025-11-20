import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

import '../../models/property_model.dart';
import '../../services/firestore_service.dart';
import '../chat/chat_page.dart';
import '../add_property/edit_property_page.dart';

class PropertyDetailPage extends StatefulWidget {
  const PropertyDetailPage({super.key});

  @override
  State<PropertyDetailPage> createState() => _PropertyDetailPageState();
}

class _PropertyDetailPageState extends State<PropertyDetailPage> {
  PropertyModel? property;
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

  Future<void> _checkFavorite() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || property == null) return;
    final fs = FirestoreService();
    final isFav = await fs.isFavorite(uid, property!.id);
    if (!mounted) return;
    setState(() => _isFavorite = isFav);
  }

  @override
  Widget build(BuildContext context) {
    final p = property;
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    final isOwner = currentUserId != null && currentUserId == p?.userId;

    if (p == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'property-image-${p.id}',
                child: PageView.builder(
                  onPageChanged: (index) =>
                      setState(() => _currentImageIndex = index),
                  itemCount: p.images.isEmpty ? 1 : p.images.length,
                  itemBuilder: (context, index) {
                    final imageUrl = p.images.isEmpty ? '' : p.images[index];
                    return Container(
                      color: Colors.grey[300],
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.home, size: 80)
                          : Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (c, e, st) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                    );
                  },
                ),
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
                      color: _isFavorite ? colorScheme.secondary : Colors.grey,
                    ),
                    onPressed: () async {
                      final uid = FirebaseAuth.instance.currentUser?.uid;
                      if (uid == null) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Veuillez vous connecter')),
                        );
                        return;
                      }
                      final fs = FirestoreService();
                      if (_isFavorite) {
                        await fs.removeFavorite(uid, p.id);
                      } else {
                        await fs.addFavorite(uid, p.id);
                      }
                      if (!mounted) return;
                      setState(() => _isFavorite = !_isFavorite);
                    },
                  ),
                ),
              ),
            ],
          ),

          // Détails
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + localisation + prix
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.grey[600],
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    p.location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.98, end: 1.0),
                        duration: const Duration(milliseconds: 360),
                        builder: (context, scale, child) => Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                        child: Text(
                          '${NumberFormat.decimalPattern('fr_FR').format(p.price)} €',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.secondary,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Infos clés
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.door_front_door,
                        '${p.rooms} pièces',
                      ),
                      _buildInfoChip(
                        context,
                        Icons.square_foot,
                        '${p.surface.toStringAsFixed(0)} m²',
                      ),
                      _buildInfoChip(
                        context,
                        Icons.home,
                        p.type,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    p.description.isNotEmpty
                        ? p.description
                        : 'Aucune description',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Boutons pour le propriétaire
                  if (isOwner) ...[const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final updated = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => EditPropertyPage(property: p),
                                ),
                              );
                              if (updated == true) {
                                // Recharger la propriété à partir de Firestore
                                final latest = await FirestoreService().getPropertyById(p.id);
                                if (!mounted) return;
                                setState(() => property = latest);
                              }
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Modifier'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.error,
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (c) => AlertDialog(
                                  title: const Text('Supprimer l\'annonce'),
                                  content: const Text('Voulez-vous vraiment supprimer cette annonce ?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, false),
                                      child: const Text('Annuler'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(c, true),
                                      child: const Text('Supprimer'),
                                    ),
                                  ],
                                ),
                              );
                              if (confirm != true) return;
                              await FirestoreService().deleteProperty(p.id);
                              if (!mounted) return;
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.delete),
                            label: const Text('Supprimer'),
                          ),
                        ),
                      ],
                    ),
                  ] else ...[const SizedBox(height: 24),
                    // Bouton contact (uniquement pour non-propriétaires)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final currentUserId =
                              FirebaseAuth.instance.currentUser?.uid;
                          if (currentUserId == null) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Veuillez vous connecter')),
                            );
                            return;
                          }
                          if (currentUserId == p.userId) return;

                          final fs = FirestoreService();
                          final chatId = await fs.getOrCreateChatForProperty(
                            currentUserId,
                            p.userId,
                            p.id,
                          );

                          if (!mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (c) => ChatConversationPage(
                                currentUserId: currentUserId,
                                otherUserId: p.userId,
                                propertyId: p.id,
                                chatId: chatId,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text('Contacter le vendeur'),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
