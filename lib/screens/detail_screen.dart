import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifeline/screens/edit_screen.dart'; // Import halaman edit yang akan kita buat

class DetailScreen extends StatelessWidget {
  // 1. Ubah tipe data yang diterima menjadi QueryDocumentSnapshot
  final QueryDocumentSnapshot document;

  const DetailScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    // Ekstrak data dan ID dari dokumen
    final data = document.data() as Map<String, dynamic>;
    final docId = document.id;
    final String nama = data['nama'] ?? 'Detail Peserta';

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail: $nama'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        // 2. Tambahkan tombol Edit di AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Data',
            onPressed: () {
              // Navigasi ke halaman Edit, kirim ID dan datanya
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => EditScreen(docId: docId, initialData: data),
              ));
            },
          ),
        ],
      ),
      body: Padding(
        // ... sisa kode body tetap sama persis seperti sebelumnya ...
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                ListTile(
                  leading: Icon(Icons.person_pin_rounded, color: Colors.red[700], size: 30),
                  title: const Text('Nama Lengkap'),
                  subtitle: Text(
                    data['nama'] ?? 'Tidak ada data',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.bloodtype_outlined, color: Colors.red[700], size: 30),
                  title: const Text('Golongan Darah'),
                  subtitle: Text(
                    data['gol_darah'] ?? 'Tidak ada data',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.location_on_outlined, color: Colors.red[700], size: 30),
                  title: const Text('Lokasi'),
                  subtitle: Text(
                    data['lokasi'] ?? 'Tidak ada data',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: Icon(Icons.phone_outlined, color: Colors.red[700], size: 30),
                  title: const Text('Nomor Telepon'),
                  subtitle: Text(
                    data['telepon'] ?? 'Tidak ada data',
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                if (data['is_urgent'] == true) ...[
                  const Divider(),
                  ListTile(
                    leading: Icon(Icons.warning_amber_rounded, color: Colors.amber[800], size: 30),
                    title: const Text('Alasan Mendesak'),
                    subtitle: Text(
                      data['alasan_mendesak'] ?? 'Tidak ada alasan spesifik',
                      style: const TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}