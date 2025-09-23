import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardScreen extends StatelessWidget {
  // Terima data user dari MainLayout
  final User? currentUser;
  const DashboardScreen({super.key, this.currentUser});

  @override
  Widget build(BuildContext context) {
    // Olah email menjadi username
    String username = "Tamu";
    if (currentUser != null && currentUser!.email != null) {
      final email = currentUser!.email!;
      var name = email.split('@')[0];
      username = name[0].toUpperCase() + name.substring(1);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tampilkan sapaan di sini
            Text(
              'Halo, Selamat Datang $username',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Konten dashboard akan muncul di sini.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}