import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lifeline/screens/add_need_screen.dart';
import 'package:lifeline/screens/detail_screen.dart';
import 'package:lifeline/screens/main_layout.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _username = '';
  String _searchQuery = '';

  // @override
  // void initState() {
  //   _extractUsername();
  //   super.initState();
  // }

  // void _extractUsername() {
  //   if (widget.email.contains('@')) {
  //     var name = widget.email.split('@')[0];
  //     _username = name[0].toUpperCase() + name.substring(1);
  //   } else {
  //     _username = widget.email;
  //   }
  // }


  // 1. Buat fungsi untuk menghapus dokumen di Firestore
  Future<void> _deleteItem(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('kebutuhan_darah').doc(docId).delete();
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data berhasil dihapus'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus data: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebutuhan Darah (Online)'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Padding(
            //   padding: const EdgeInsets.only(left: 4.0, bottom: 10.0),
            //   child: Text(
            //     'Halo, Selamat Datang $_username',
            //     style: const TextStyle(
            //       fontSize: 18,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Cari (Nama atau Gol. Darah)',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('kebutuhan_darah').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('Belum ada kebutuhan darah.'));
                  }

                  final docs = snapshot.data!.docs;
                  final filteredDocs = _searchQuery.isEmpty
                      ? docs
                      : docs.where((doc) {
                          final data = doc.data() as Map<String, dynamic>;
                          final nama = data['nama'].toString().toLowerCase();
                          final golDarah = data['gol_darah'].toString().toLowerCase();
                          final query = _searchQuery.toLowerCase();
                          return nama.contains(query) || golDarah.contains(query);
                        }).toList();
                  
                  if (filteredDocs.isEmpty) {
                    return const Center(child: Text('Data tidak ditemukan.'));
                  }

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final document = filteredDocs[index];
                      final data = document.data() as Map<String, dynamic>;

                      // 2. Bungkus Card dengan widget Dismissible
                      return Dismissible(
                        // 3. Berikan 'key' unik untuk setiap item, ID dokumen sempurna untuk ini
                        key: Key(document.id),
                        // 4. Aksi yang dijalankan setelah item berhasil digeser
                        onDismissed: (direction) {
                          _deleteItem(document.id);
                        },
                        // 5. Latar belakang yang muncul saat item digeser
                        background: Container(
                          color: Colors.red[700],
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 5),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red[700],
                              child: Text(
                                data['gol_darah'] ?? '?',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(data['nama'] ?? 'Tanpa Nama'),
                            subtitle: Text(data['lokasi'] ?? 'Tanpa Lokasi'),
                            trailing: (data['is_urgent'] == true)
                                ? Icon(Icons.warning_amber_rounded, color: Colors.amber[800])
                                : null,
                            onTap: () {
                              // Sekarang kita kirim seluruh 'document' yang berisi ID dan data
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => DetailScreen(document: document),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
        tooltip: 'Tambah Kebutuhan Darah',
      ),
    );
  }
}