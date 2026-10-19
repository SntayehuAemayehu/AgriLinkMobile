import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});
  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  final _qty = TextEditingController();
  final _price = TextEditingController();
  final _region = TextEditingController();
  final _woreda = TextEditingController();
  String _crop = 'teff';
  File? _image;
  bool _loading = false;

  final _crops = ['teff', 'maize', 'wheat', 'barley', 'sorghum', 'coffee', 'vegetables', 'fruits', 'other'];

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _takePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera, imageQuality: 70);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<void> _save() async {
    if (_title.text.isEmpty || _qty.text.isEmpty || _price.text.isEmpty || _region.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fill title, quantity, price, region')));
      return;
    }
    setState(() => _loading = true);
    final res = await ApiService.createProduct({
      'crop_type': _crop,
      'title': _title.text.trim(),
      'description': _desc.text.trim(),
      'quantity_kg': _qty.text.trim(),
      'price_per_kg': _price.text.trim(),
      'region': _region.text.trim(),
      'woreda': _woreda.text.trim(),
    }, image: _image);
    setState(() => _loading = false);
    if (!mounted) return;
    if (res['status'] == 201) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product listed!')));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${res['body']}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List Your Produce'), backgroundColor: Colors.green, foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 180, width: double.infinity,
              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
              child: _image == null
                  ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Tap to add photo'),
                    ])
                  : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_image!, fit: BoxFit.cover)),
            ),
          ),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            TextButton.icon(onPressed: _pickImage, icon: const Icon(Icons.photo), label: const Text('Gallery')),
            TextButton.icon(onPressed: _takePhoto, icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
          ]),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _crop,
            items: _crops.map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1)))).toList(),
            onChanged: (v) => setState(() => _crop = v!),
            decoration: const InputDecoration(labelText: 'Crop Type', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          TextField(controller: _title, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _desc, maxLines: 3, decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _qty, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Quantity (kg)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price per kg (ETB)', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _region, decoration: const InputDecoration(labelText: 'Region', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: _woreda, decoration: const InputDecoration(labelText: 'Woreda', border: OutlineInputBorder())),
          const SizedBox(height: 25),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: _loading ? null : _save,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
            child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Publish Listing'),
          )),
        ]),
      ),
    );
  }
}