import 'package:flutter/material.dart';
import '../services/firestore_service.dart';


class LegacyAddPropertyPage extends StatefulWidget {
  const LegacyAddPropertyPage({super.key});

  @override
  State<LegacyAddPropertyPage> createState() => _LegacyAddPropertyPageState();
}

class _LegacyAddPropertyPageState extends State<LegacyAddPropertyPage> {
  final _title = TextEditingController();
  final _price = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajouter un bien')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _title, decoration: const InputDecoration(labelText: 'Titre')),
            TextField(controller: _price, decoration: const InputDecoration(labelText: 'Prix'), keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      final title = _title.text.trim();
                      final price = double.tryParse(_price.text.trim()) ?? 0.0;
                      if (title.isEmpty || price <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Titre et prix valides requis')));
                        return;
                      }
                      setState(() => _loading = true);
                      try {
                        await FirestoreService().addProperty({
                          'title': title,
                          'description': '',
                          'price': price,
                          'type': 'sale',
                          'latitude': 0.0,
                          'longitude': 0.0,
                          'images': [],
                        });
                        if (!mounted) return;
                        Navigator.pop(context);
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
                    child: const Text('Publier'),
                  )
          ],
        ),
      ),
    );
  }
}
