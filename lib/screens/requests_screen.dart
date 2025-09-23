import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifeline/screens/add_need_screen.dart';
// Halaman detail untuk request akan kita buat/sesuaikan nanti

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebutuhan Darah'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // 1. Ubah sumber stream ke 'blood_requests' dan urutkan berdasarkan yang terbaru
        stream: FirebaseFirestore.instance
            .collection('blood_requests')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Belum ada permintaan darah.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;

              // 2. Desain kartu baru yang lebih informatif
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: ListTile(
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red[700],
                    child: Text(
                      data['gol_darah'] ?? '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(data['judul'] ?? 'Tanpa Judul', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['lokasi_rs'] ?? 'Lokasi tidak diketahui'),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(data['status'] ?? 'Mencari'),
                        backgroundColor: Colors.amber[100],
                        padding: EdgeInsets.zero,
                      )
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    // Navigasi ke halaman detail permintaan (akan kita buat nanti)
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddNeedScreen()),
          );
        },
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Buat Permintaan Darah',
      ),
    );
  }
}