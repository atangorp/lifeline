import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditScreen extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> initialData;

  const EditScreen({super.key, required this.docId, required this.initialData});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Siapkan controller untuk setiap field
  late TextEditingController _nameController;
  late TextEditingController _bloodTypeController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _reasonController;
  
  bool _isUrgent = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Isi controller dengan data awal saat halaman dibuka
    _nameController = TextEditingController(text: widget.initialData['nama']);
    _bloodTypeController = TextEditingController(text: widget.initialData['gol_darah']);
    _locationController = TextEditingController(text: widget.initialData['lokasi']);
    _phoneController = TextEditingController(text: widget.initialData['telepon']);
    _reasonController = TextEditingController(text: widget.initialData['alasan_mendesak']);
    _isUrgent = widget.initialData['is_urgent'] ?? false;
  }
  
  Future<void> _submitUpdate() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final Map<String, dynamic> updatedData = {
          'nama': _nameController.text,
          'gol_darah': _bloodTypeController.text,
          'lokasi': _locationController.text,
          'telepon': _phoneController.text,
          'is_urgent': _isUrgent,
          'alasan_mendesak': _reasonController.text,
        };

        // Gunakan .doc(widget.docId).update() untuk memperbarui dokumen yang ada
        await FirebaseFirestore.instance.collection('kebutuhan_darah').doc(widget.docId).update(updatedData);

        if (mounted) {
          // Kembali 2x untuk sampai ke Home Screen
          Navigator.of(context)..pop()..pop();
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui data: $error')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose semua controller
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
        title: const Text('Edit Data Kebutuhan'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nama Pasien')),
              TextFormField(controller: _bloodTypeController, decoration: const InputDecoration(labelText: 'Golongan Darah')),
              TextFormField(controller: _locationController, decoration: const InputDecoration(labelText: 'Lokasi')),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Nomor Telepon'), keyboardType: TextInputType.phone),
              SwitchListTile(
                title: const Text('Kebutuhan Mendesak (Urgent)?'),
                value: _isUrgent,
                onChanged: (value) {
                  setState(() {
                    _isUrgent = value;
                  });
                },
              ),
              if (_isUrgent)
                TextFormField(controller: _reasonController, decoration: const InputDecoration(labelText: 'Alasan Mendesak')),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submitUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[800],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Simpan Perubahan'),
                    )
            ],
          ),
        ),
      ),
    );
  }
}