import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RequestDetailScreen extends StatelessWidget {
  final DocumentSnapshot requestDoc;
  const RequestDetailScreen({super.key, required this.requestDoc});

  @override
  Widget build(BuildContext context) {
    final data = requestDoc.data() as Map<String, dynamic>;
    final Timestamp timestamp = data['timestamp'] ?? Timestamp.now();
    final String formattedDate = DateFormat('EEEE, dd MMMM yyyy, HH:mm', 'id_ID').format(timestamp.toDate());

    return Scaffold(
      appBar: AppBar(
        title: Text(data['judul'] ?? 'Detail Permintaan'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['judul'] ?? 'Tanpa Judul', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Chip(label: Text('Status: ${data['status'] ?? 'Mencari'}'), backgroundColor: Colors.amber[100]),
            const Divider(height: 30),
            ListTile(leading: const Icon(Icons.bloodtype, color: Colors.red), title: const Text('Golongan Darah Dibutuhkan'), subtitle: Text(data['gol_darah'] ?? 'Tidak ada data')),
            ListTile(leading: const Icon(Icons.local_hospital, color: Colors.red), title: const Text('Lokasi Rumah Sakit'), subtitle: Text(data['lokasi_rs'] ?? 'Tidak ada data')),
            ListTile(leading: const Icon(Icons.phone, color: Colors.red), title: const Text('Telepon Kontak'), subtitle: Text(data['telepon_kontak'] ?? 'Tidak ada data')),
            ListTile(leading: const Icon(Icons.access_time, color: Colors.red), title: const Text('Dibuat Pada'), subtitle: Text(formattedDate)),
            const Divider(height: 30),
            Text('Deskripsi Lengkap', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(data['deskripsi'] ?? 'Tidak ada deskripsi.', style: const TextStyle(fontSize: 16, height: 1.5)),
          ],
        ),
      ),
    );
  }
}