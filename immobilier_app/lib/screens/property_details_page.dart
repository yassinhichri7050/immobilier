import 'package:flutter/material.dart';
import '../models/property_model.dart';

class PropertyDetailsPage extends StatelessWidget {
  const PropertyDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    PropertyModel? property;
    if (args != null && args is PropertyModel) property = args;

    return Scaffold(
      appBar: AppBar(title: Text(property?.title ?? 'Détails du bien')),
      body: property == null
          ? const Center(child: Text('Aucune information disponible'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (property.images.isNotEmpty)
                    Image.network(property.images.first, width: double.infinity, height: 200, fit: BoxFit.cover),
                  const SizedBox(height: 12),
                  Text(property.title, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text('${property.type} • ${property.price.toStringAsFixed(0)} €', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Text(property.description),
                  const SizedBox(height: 12),
                  const Text('Carte (à intégrer avec Google Maps)'),
                ],
              ),
            ),
    );
  }
}
