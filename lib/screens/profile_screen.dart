import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, User? currentUser});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Halaman Profil')),
    );
  }
}