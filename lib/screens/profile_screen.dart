import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:lifeline/login_or_register.dart';
import 'package:geolocator/geolocator.dart';

class ProfileScreen extends StatefulWidget {
  final User? currentUser;
  const ProfileScreen({super.key, this.currentUser});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isUpdatingLocation = false;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginOrRegisterPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  Future<void> _updateUserLocation() async {
    // ... (fungsi _updateUserLocation tetap sama persis)
    setState(() { _isUpdatingLocation = true; });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak.')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak permanen, buka pengaturan untuk mengizinkan.')));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      await FirebaseFirestore.instance.collection('users').doc(widget.currentUser?.uid).update({
        'lokasi_koordinat': GeoPoint(position.latitude, position.longitude),
        'lokasi_terakhir_update': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lokasi berhasil diperbarui!'), backgroundColor: Colors.green));

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
    } finally {
      if(mounted) {
        setState(() { _isUpdatingLocation = false; });
      }
    }
  }

  Future<void> _showEditProfileDialog(Map<String, dynamic> currentData) async {
    // ... (fungsi _showEditProfileDialog tetap sama persis)
  }

  Future<void> _updateProfileData(String newName, DateTime? newDate) async {
    // ... (fungsi _updateProfileData tetap sama persis)
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection('users').doc(widget.currentUser?.uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Profil tidak ditemukan.'));
          }

          final userData = snapshot.data!.data()!;
          final lastDonation = (userData['tanggal_donor_terakhir'] as Timestamp?)?.toDate();

          // --- PERBAIKAN LAYOUT DI SINI ---
          return SingleChildScrollView( // 1. Bungkus dengan SingleChildScrollView
            padding: const EdgeInsets.all(16.0),
            child: Column( // 2. Gunakan Column biasa, bukan di dalam Center
              crossAxisAlignment: CrossAxisAlignment.stretch, // Agar tombol-tombolnya selebar layar
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    icon: const Icon(Icons.edit_note),
                    tooltip: 'Edit Profil',
                    onPressed: () => _showEditProfileDialog(userData),
                  ),
                ),
                // Informasi Profil
                Text(
                  userData['nama'] ?? 'Nama Pengguna',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  userData['email'] ?? 'Tidak ada email',
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Chip(
                    label: Text('Gol. Darah: ${userData['gol_darah'] ?? '?'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.red[100],
                  ),
                ),
                const Divider(height: 40),

                // Detail Lainnya
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.red),
                  title: const Text('Donor Terakhir'),
                  subtitle: Text(lastDonation == null ? 'Belum pernah donor' : DateFormat('dd MMMM yyyy').format(lastDonation)),
                ),
                ListTile(
                  leading: const Icon(Icons.star, color: Colors.amber),
                  title: const Text('Pangkat'),
                  subtitle: Text(userData['level'] ?? 'Rekrutan'),
                ),
                const SizedBox(height: 30),

                // Tombol Aksi
                _isUpdatingLocation
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton.icon(
                        icon: const Icon(Icons.my_location),
                        label: const Text('Perbarui Lokasi Saya'),
                        onPressed: _updateUserLocation,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                      ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[800],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}