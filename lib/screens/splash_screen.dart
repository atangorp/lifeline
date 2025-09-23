import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifeline/login_or_register.dart';
// import 'package:lifeline/screens/home_screen.txt';
import 'package:lifeline/screens/main_layout.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // Di dalam file splash_screen.dart
  Future<void> _checkAuthStatus() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Jika ada, langsung ke MainLayout TANPA mengirim email
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const MainLayout(),
      ));
    } else {
      // Jika tidak ada, ke halaman Login/Register
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginOrRegisterPage(),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI Splash Screen tidak berubah
    return Scaffold(
      backgroundColor: Colors.red[800],
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bloodtype, size: 80, color: Colors.white),
            const SizedBox(height: 20),
            const Text('LifeLine', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 40),
            const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            const SizedBox(height: 20),
            const Text('Dibuat oleh: Fathan', style: TextStyle(fontSize: 14, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}