import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifeline/screens/add_need_screen.dart';
import 'request_detail_screen.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
title: Image.asset('assets/images/app_logo.png', height: 35),
centerTitle: true, // Agar logo di tengah
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Cari (Judul atau Gol. Darah)',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                final requests = _searchQuery.isEmpty
                    ? snapshot.data!.docs
                    : snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final title = (data['judul'] ?? '').toString().toLowerCase();
                        final bloodType = (data['gol_darah'] ?? '').toString().toLowerCase();
                        final query = _searchQuery.toLowerCase();
                        return title.contains(query) || bloodType.contains(query);
                      }).toList();
                
                if (requests.isEmpty) {
                  return const Center(child: Text('Pencarian tidak ditemukan.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final doc = requests[index];
                    final data = doc.data() as Map<String, dynamic>;


                    // Cara yang benar adalah menganimasikan Card-nya langsung
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
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => RequestDetailScreen(requestDoc: doc),
    ),
  );
},
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      // Tombol floatingActionButton diletakkan di sini, sebagai properti Scaffold
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