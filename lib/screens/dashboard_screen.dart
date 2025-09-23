import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends StatelessWidget {
  final User? currentUser;
  const DashboardScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser?.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Tidak dapat memuat data pengguna.'));
          }

          final userData = snapshot.data!.data();
          final String username = userData?['nama'] ?? 'Pengguna';
          final int drs = userData?['drs'] ?? 0;
          final String level = userData?['level'] ?? 'Rekrutan';

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Kartu Sambutan
              Text(
                'Halo, Selamat Datang ${username.split(' ')[0]}!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Kartu Skor Kesiapan Donor (DRS)
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      // Gauge/Indikator Skor
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: drs / 100, // Nilai dari 0.0 sampai 1.0
                              strokeWidth: 8,
                              backgroundColor: Colors.grey[300],
                              valueColor: AlwaysStoppedAnimation<Color>(drs > 70 ? Colors.green : Colors.amber),
                            ),
                            Center(
                              child: Text(
                                '$drs',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Teks Penjelasan
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Skor Kesiapan Donor (DRS)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            SizedBox(height: 4),
                            Text('Skor ini menunjukkan kesiapan Anda untuk melakukan donor darah.'),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Kartu Level Pahlawan Darah
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.shield, color: Colors.blue, size: 40),
                  title: const Text('Pangkat Pahlawan Darah'),
                  subtitle: Text(level, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              // Placeholder untuk fitur selanjutnya
              const SizedBox(height: 20),
              Text(
                'Aksi Cepat',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 10),
              // Tombol-tombol aksi bisa ditambahkan di sini nanti
            ],
          );
        },
      ),
    );
  }
}