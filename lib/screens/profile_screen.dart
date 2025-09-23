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

  // --- SEMUA FUNGSI YANG HILANG ADA DI SINI ---

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
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Izin lokasi ditolak permanen, buka pengaturan.')));
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
    final nameController = TextEditingController(text: currentData['nama']);
    DateTime? selectedDate = (currentData['tanggal_donor_terakhir'] as Timestamp?)?.toDate();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profil'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                    ),
                    const SizedBox(height: 20),
                    Text('Tanggal Donor Terakhir: ${selectedDate == null ? 'Belum diatur' : DateFormat('dd MMMM yyyy').format(selectedDate!)}'),
                    ElevatedButton(
                      child: const Text('Pilih Tanggal'),
                      onPressed: () async {
                        final DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null && picked != selectedDate) {
                          setState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Simpan'),
              onPressed: () async {
                await _updateProfileData(nameController.text, selectedDate);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateProfileData(String newName, DateTime? newDate) async {
    int newDrs = 10;
    if (newDate != null) {
      final difference = DateTime.now().difference(newDate).inDays;
      if (difference > 90) {
        newDrs = 95;
      } else {
        newDrs = (difference / 90 * 80).round() + 10;
      }
    }

    await FirebaseFirestore.instance.collection('users').doc(widget.currentUser?.uid).update({
      'nama': newName,
      'tanggal_donor_terakhir': newDate,
      'drs': newDrs,
    });
    setState(() {});
  }

  // --- BATAS FUNGSI ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
        actions: [
          FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance.collection('users').doc(widget.currentUser?.uid).get(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists) {
                return IconButton(
                  icon: const Icon(Icons.edit_note),
                  tooltip: 'Edit Profil',
                  onPressed: () => _showEditProfileDialog(snapshot.data!.data()!),
                );
              }
              return const SizedBox.shrink();
            }
          ),
        ],
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(userData['nama'] ?? 'Nama Pengguna', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(userData['email'] ?? 'Tidak ada email', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Center(
                  child: Chip(
                    label: Text('Gol. Darah: ${userData['gol_darah'] ?? '?'}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    backgroundColor: Colors.red[100],
                  ),
                ),
                const Divider(height: 30),
                ListTile(
                  leading: const Icon(Icons.star_border, color: Colors.amber),
                  title: const Text('Poin'),
                  trailing: Text('${userData['poin'] ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.shield_outlined, color: Colors.blue),
                  title: const Text('Pangkat'),
                  trailing: Text(userData['level'] ?? 'Rekrutan', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ListTile(
                  leading: const Icon(Icons.speed, color: Colors.green),
                  title: const Text('Skor Kesiapan Donor (DRS)'),
                  trailing: Text('${userData['drs'] ?? 0}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 30),
                ListTile(
                  leading: const Icon(Icons.calendar_today, color: Colors.red),
                  title: const Text('Donor Terakhir'),
                  subtitle: Text(lastDonation == null ? 'Belum pernah donor' : DateFormat('dd MMMM yyyy').format(lastDonation)),
                ),
                const SizedBox(height: 30),
                if (_isUpdatingLocation)
                  const CircularProgressIndicator()
                else
                  ElevatedButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text('Perbarui Lokasi Saya'),
                    onPressed: _updateUserLocation,
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                  ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[800],
                    minimumSize: const Size.fromHeight(40),
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