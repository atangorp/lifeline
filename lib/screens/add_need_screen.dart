import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

class AddNeedScreen extends StatefulWidget {
  const AddNeedScreen({super.key});

  @override
  State<AddNeedScreen> createState() => _AddNeedScreenState();
}

class _AddNeedScreenState extends State<AddNeedScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;

  Future<void> _submitRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anda harus login untuk membuat permintaan.')),
          );
        }
        setState(() { _isLoading = false; });
        return;
      }

      try {
        Position? currentPosition;
        try {
          currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
        } catch (e) {
          print("Tidak bisa mendapatkan lokasi: $e");
        }

        final Map<String, dynamic> newRequest = {
          'judul': _titleController.text,
          'gol_darah': _bloodTypeController.text.toUpperCase(),
          'lokasi_rs': _locationController.text,
          'telepon_kontak': _contactPhoneController.text,
          'deskripsi': _descriptionController.text,
          'status': 'Mencari',
          'requester_uid': currentUser.uid,
          'timestamp': FieldValue.serverTimestamp(),
          if (currentPosition != null)
            'lokasi_koordinat': GeoPoint(currentPosition.latitude, currentPosition.longitude),
        };

        await FirebaseFirestore.instance.collection('blood_requests').add(newRequest);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal mengirim permintaan: $error')),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bloodTypeController.dispose();
    _locationController.dispose();
    _contactPhoneController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Permintaan Darah'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Judul Permintaan (Cth: Butuh Darah untuk Nenek)'),
                validator: (value) => value!.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(labelText: 'Golongan Darah (Cth: A+, B-)'),
                validator: (value) => value!.isEmpty ? 'Golongan darah tidak boleh kosong' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Nama & Kota Rumah Sakit'),
                validator: (value) => value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _contactPhoneController,
                decoration: const InputDecoration(labelText: 'Telepon Kontak'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Deskripsi Singkat'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Kirim Permintaan'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}