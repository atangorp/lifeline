import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddNeedScreen extends StatefulWidget {
  const AddNeedScreen({super.key});

  @override
  State<AddNeedScreen> createState() => _AddNeedScreenState();
}

class _AddNeedScreenState extends State<AddNeedScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _reasonController = TextEditingController();

  // 1. Tambahkan state untuk mengontrol switch, default-nya true
  bool _isUrgent = true;
  bool _isLoading = false;

  Future<void> _submitData() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final Map<String, dynamic> newData = {
          'nama': _nameController.text,
          'gol_darah': _bloodTypeController.text,
          'lokasi': _locationController.text,
          'telepon': _phoneController.text,
          // 3. Gunakan nilai dari state _isUrgent, bukan hardcode 'true'
          'is_urgent': _isUrgent,
          // Hanya tambahkan alasan jika statusnya urgent
          'alasan_mendesak': _isUrgent ? _reasonController.text : '',
        };

        await FirebaseFirestore.instance.collection('kebutuhan_darah').add(newData);

        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan data: $error')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bloodTypeController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _reasonController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Kebutuhan Darurat'),
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Pasien'),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(labelText: 'Golongan Darah (Contoh: A+, O-, dll)'),
                validator: (value) => value!.isEmpty ? 'Golongan darah tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Lokasi (Contoh: RS. Sehat Selalu)'),
                validator: (value) => value!.isEmpty ? 'Lokasi tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon Kontak'),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Nomor telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 10),
              // 2. Tambahkan SwitchListTile di dalam ListView
              SwitchListTile(
                title: const Text('Kebutuhan Mendesak (Urgent)?'),
                value: _isUrgent,
                onChanged: (newValue) {
                  setState(() {
                    _isUrgent = newValue;
                  });
                },
              ),
              // Tampilkan field Alasan hanya jika switch 'urgent' aktif
              if (_isUrgent)
                TextFormField(
                  controller: _reasonController,
                  decoration: const InputDecoration(labelText: 'Alasan Mendesak (Contoh: Operasi)'),
                  validator: (value) {
                    // Jadikan opsional, tapi jika urgent dan kosong, beri peringatan
                    if (_isUrgent && (value == null || value.isEmpty)) {
                      return 'Alasan tidak boleh kosong jika mendesak';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Data'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}