import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/property_model.dart';

class PropertyCard extends StatelessWidget {
  final PropertyModel property;
  final bool horizontal;

  const PropertyCard({
    super.key,
    required this.property,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (horizontal) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        child: SizedBox(
          width: 240,
          height: 140,
          child: Row(
            children: [
              // IMAGE + HERO (horizontal)
              Hero(
                tag: 'property-image-${property.id}',
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                  child: SizedBox(
                    width: 120,
                    height: 140,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          color: Colors.grey[300],
                          child: property.images.isNotEmpty
                              ? Image.network(
                                  property.images[0],
                                  fit: BoxFit.cover,
                                  errorBuilder: (c, e, st) =>
                                      const Icon(Icons.image_not_supported),
                                )
                              : const Icon(Icons.home),
                        ),
                        Positioned(
                          top: 8,
                          right: 8,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.96, end: 1.0),
                            duration: const Duration(milliseconds: 360),
                            builder: (context, scale, child) => Transform.scale(
                              scale: scale,
                              child: child,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'NOUVEAU',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        property.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.black87,
                                ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: colorScheme.secondary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              property.location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Text(
                          property.price > 0
                              ? '${NumberFormat.decimalPattern('fr_FR').format(property.price)} €'
                              : 'Prix sur demande',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                color: colorScheme.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // VERTICAL CARD
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // IMAGE + HERO (vertical)
          Hero(
            tag: 'property-image-${property.id}',
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: Container(
                width: double.infinity,
                height: 180,
                color: Colors.grey[300],
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    property.images.isNotEmpty
                        ? Image.network(
                            property.images[0],
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, st) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.home),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.96, end: 1.0),
                        duration: const Duration(milliseconds: 360),
                        builder: (context, scale, child) => Transform.scale(
                          scale: scale,
                          child: child,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.22),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'NOUVEAU',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.favorite_border,
                          size: 18,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          property.type,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 14,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Prix
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            property.price > 0
                                ? '${NumberFormat.decimalPattern('fr_FR').format(property.price)} €'
                                : 'Prix sur demande',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'Prix',
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                    // Pièces
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.door_front_door,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${property.rooms}',
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'pièces',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                    // Surface
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.square_foot,
                            size: 18,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            property.surface.toStringAsFixed(0),
                            maxLines: 1,
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            'm²',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
