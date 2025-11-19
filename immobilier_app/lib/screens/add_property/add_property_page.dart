import 'dart:io';
// dart:typed_data not required (Uint8List available via foundation)

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import '../../services/firestore_service.dart';
import '../../services/storage_service.dart';

class AddPropertyPage extends StatefulWidget {
  const AddPropertyPage({super.key});

  @override
  State<AddPropertyPage> createState() => _AddPropertyPageState();
}

class _AddPropertyPageState extends State<AddPropertyPage> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _surfaceController = TextEditingController();
  final _roomsController = TextEditingController();
  final _locationController = TextEditingController();

  String _selectedType = 'Appartement';
  bool _loading = false;
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _images = [];
  final List<Uint8List?> _imageBytes = [];

  final List<String> _propertyTypes = ['Maison', 'Appartement', 'Terrain', 'Commerce'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _surfaceController.dispose();
    _roomsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage(imageQuality: 75);
    if (picked.isEmpty) return;
    if (kIsWeb) {
      for (final p in picked) {
        final b = await p.readAsBytes();
        if (!mounted) return;
        setState(() {
          _images.add(p);
          _imageBytes.add(b);
        });
      }
    } else {
      if (!mounted) return;
      setState(() {
        _images.addAll(picked);
        for (var i = 0; i < picked.length; i++) {
          _imageBytes.add(null);
        }
      });
    }
  }

  Future<void> _removeImageAt(int index) async {
    if (!mounted) return;
    setState(() {
      _images.removeAt(index);
      if (_imageBytes.length > index) _imageBytes.removeAt(index);
    });
  }

  // [FIX] Gestion complète du flux avec try/catch/finally + logs détaillés
  Future<void> _submit() async {
    debugPrint('[AddPropertyPage] _submit() START');
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez vous connecter')));
      return;
    }

    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim();
    if (title.isEmpty || priceText.isEmpty) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez remplir le titre et le prix.')));
      return;
    }

    final price = double.tryParse(priceText);
    final surface = double.tryParse(_surfaceController.text.trim()) ?? 0.0;
    final rooms = int.tryParse(_roomsController.text.trim()) ?? 0;
    if (price == null) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Prix invalide')));
      return;
    }

    debugPrint('[AddPropertyPage] _submit() - Validation passed, setting isLoading=true');
    // [LOADING STATE] Démarrer le spinner du bouton
    setState(() => _loading = true);
    
    try {
      final storage = StorageService();
      final List<String> imageUrls = [];
      
      debugPrint('[AddPropertyPage] _submit() - Images count: ${_images.length}');

      // [IMAGE UPLOAD] Uploader chaque image avec timeout intégré dans StorageService
      for (var i = 0; i < _images.length; i++) {
        final img = _images[i];
        final path = 'properties/$uid/${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        
        debugPrint('[AddPropertyPage] _submit() - Uploading image ${i + 1}/${_images.length}...');
        try {
          // uploadXFile gère maintenant timeout + try/catch internement
          final url = await storage.uploadXFile(img, path);
          debugPrint('[AddPropertyPage] _submit() - Image ${i + 1} uploaded successfully: $url');
          imageUrls.add(url);
        } catch (e) {
          // En cas d'erreur d'une image, l'afficher mais arrêter l'upload des autres
          debugPrint('[AddPropertyPage] _submit() - ERROR uploading image ${i + 1}: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Échec upload image ${i + 1}: $e'),
                duration: const Duration(seconds: 3),
                backgroundColor: Colors.red,
              ),
            );
          }
          rethrow; // Relancer pour que le catch global le capture et arrête le flux
        }
      }

      debugPrint('[AddPropertyPage] _submit() - All images uploaded. Starting Firestore addProperty...');

      // [FIRESTORE] Ajouter le document avec les images (ou liste vide si aucune image)
      final data = {
        'title': title,
        'description': _descriptionController.text.trim(),
        'price': price,
        'surface': surface,
        'type': _selectedType,
        'rooms': rooms,
        'location': _locationController.text.trim(),
        'userId': uid,
        'latitude': 0.0,
        'longitude': 0.0,
        'images': imageUrls, // Peut être vide si aucune image sélectionnée
        'isFeatured': false,
      };

      await FirestoreService().addProperty(data);
      debugPrint('[AddPropertyPage] _submit() - Firestore addProperty completed successfully');
      
      if (mounted) {
        debugPrint('[AddPropertyPage] _submit() - Navigating back...');
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propriété ajoutée avec succès'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // [ERROR HANDLING] Affiche une erreur utilisateur lisible si quelque chose échoue
      debugPrint('[AddPropertyPage] _submit() - EXCEPTION in try block: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la publication: $e'),
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      // [LOADING STATE] Toujours remettre l'état de chargement à false, même en cas d'erreur
      debugPrint('[AddPropertyPage] _submit() - Setting isLoading=false in finally block');
      if (mounted) {
        setState(() => _loading = false);
        debugPrint('[AddPropertyPage] _submit() - isLoading set to false, UI should be responsive');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter une propriété')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Titre',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: _propertyTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
                onChanged: (value) => setState(() => _selectedType = value ?? _selectedType),
                decoration: InputDecoration(
                  labelText: 'Type',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _priceController,
                      decoration: InputDecoration(
                        labelText: 'Prix (€)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _surfaceController,
                      decoration: InputDecoration(
                        labelText: 'Surface (m²)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _roomsController,
                      decoration: InputDecoration(
                        labelText: 'Pièces',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Localisation',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Images picker
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...List.generate(_images.length, (index) {
                    final img = _images[index];
                    final bytes = _imageBytes.length > index ? _imageBytes[index] : null;
                    return GestureDetector(
                      onTap: () async {
                        final remove = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Supprimer'),
                            content: const Text('Supprimer cette image ?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Annuler')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Supprimer')),
                            ],
                          ),
                        );
                        if (remove == true) await _removeImageAt(index);
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: bytes != null
                            ? Image.memory(
                                bytes,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[300]),
                              )
                            : Image.file(
                                File(img.path),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(width: 80, height: 80, color: Colors.grey[300]),
                              ),
                      ),
                    );
                  }),

                  // Add button
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.grey[200]),
                      child: const Icon(Icons.add_a_photo, color: Colors.grey),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              // Bouton publier avec état de chargement intégré
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            ),
                            SizedBox(width: 12),
                            Text('Publication...'),
                          ],
                        )
                      : const Text('Publier', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
