// lib/auth_gate.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lifeline/login_or_register.dart'; // Import file baru
import 'package:lifeline/screens/home_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final userEmail = snapshot.data!.email ?? 'No Email';
            return HomeScreen(email: userEmail);
          } else {
            // Arahkan ke LoginOrRegisterPage
            return const LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}