import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatelessWidget {
  final User? currentUser;
  const DashboardScreen({super.key, this.currentUser});

  // Widget Kartu Aksi Cerdas (Tidak berubah)
  Widget _buildSmartActionCard(Map<String, dynamic> userData) {
    final int drs = userData['drs'] ?? 0;
    final Timestamp? lastDonationTimestamp = userData['tanggal_donor_terakhir'];
      
    if (drs > 90) {
      return Card(
        elevation: 4,
        color: Colors.green[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 40),
              const SizedBox(height: 8),
              const Text('Anda Siap Menjadi Pahlawan!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Skor Kesiapan Donor (DRS) Anda tinggi. Jadwalkan donasi Anda sekarang.', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () { /* Navigasi ke tab Event */ },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Jadwalkan Donor Sekarang', style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        ),
      );
    } else {
      String cooldownText = 'Anda dalam masa pemulihan.';
      if(lastDonationTimestamp != null) {
        final nextDonationDate = lastDonationTimestamp.toDate().add(const Duration(days: 90));
        final daysRemaining = nextDonationDate.difference(DateTime.now()).inDays;
        if (daysRemaining > 0) {
          cooldownText = 'Anda bisa donor lagi dalam $daysRemaining hari.';
        }
      }
      return Card(
        elevation: 4,
        color: Colors.amber[50],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const Icon(Icons.hourglass_top, color: Colors.amber, size: 40),
              const SizedBox(height: 8),
              const Text('Waktunya Pemulihan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(cooldownText, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
  }

  // --- FUNGSI WIDGET PERMINTAAN TERDEKAT (DENGAN LOGIKA BARU) ---
  Widget _buildNearbyRequests(BuildContext context, Map<String, dynamic>? userData) {
    final GeoPoint? userLocation = userData?['lokasi_koordinat'];

    if (userLocation == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text('Permintaan Darurat Terdekat', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('blood_requests').where('status', isEqualTo: 'Mencari').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Text('Tidak ada permintaan darurat saat ini.');
            }

            // --- LOGIKA BARU DIMULAI DI SINI ---
            // 1. Saring (filter) dulu permintaan yang punya lokasi
            var requestsWithLocation = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return data['lokasi_koordinat'] != null;
            }).toList();

            // 2. Urutkan (sort) daftar yang sudah difilter
            requestsWithLocation.sort((a, b) {
              final aData = a.data() as Map<String, dynamic>;
              final bData = b.data() as Map<String, dynamic>;
              final aLocation = aData['lokasi_koordinat'] as GeoPoint;
              final bLocation = bData['lokasi_koordinat'] as GeoPoint;

              final distanceA = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, aLocation.latitude, aLocation.longitude);
              final distanceB = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, bLocation.latitude, bLocation.longitude);
              return distanceA.compareTo(distanceB);
            });
            // --- LOGIKA BARU SELESAI ---

            if (requestsWithLocation.isEmpty) {
              return const Text('Tidak ada permintaan darurat terdekat.');
            }

            return ListView.builder(
              itemCount: requestsWithLocation.length > 2 ? 2 : requestsWithLocation.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final doc = requestsWithLocation[index];
                final data = doc.data() as Map<String, dynamic>;
                final requestLocation = data['lokasi_koordinat'] as GeoPoint;
                final distanceInMeters = Geolocator.distanceBetween(userLocation.latitude, userLocation.longitude, requestLocation.latitude, requestLocation.longitude);
                final distanceText = '${(distanceInMeters / 1000).toStringAsFixed(1)} km dari Anda';

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(child: Text(data['gol_darah'] ?? '?')),
                    title: Text(data['judul'] ?? 'Tanpa Judul'),
                    subtitle: Text(distanceText),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () { /* Navigasi ke detail permintaan */ },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
title: Image.asset('assets/images/app_logo.png', height: 35),
centerTitle: true, // Agar logo di tengah
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(currentUser?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Tidak dapat memuat data pengguna.'));
          }

          final userData = snapshot.data!.data()!;
          final String username = userData['nama'] ?? 'Pengguna';
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text('Halo, Selamat Datang ${username.split(' ')[0]}!', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              _buildSmartActionCard(userData),
              _buildNearbyRequests(context, userData), // Panggilan widget
              const SizedBox(height: 20),
              Text('Statistik Anda', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.shield, color: Colors.blue, size: 40),
                  title: const Text('Pangkat Pahlawan Darah'),
                  subtitle: Text(userData['level'] ?? 'Rekrutan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              Card(
                elevation: 2,
                child: ListTile(
                  leading: Icon(Icons.speed, color: userData['drs'] > 70 ? Colors.green : Colors.amber, size: 40),
                  title: const Text('Skor Kesiapan Donor (DRS)'),
                  subtitle: Text('${userData['drs'] ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}