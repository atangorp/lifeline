import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:lifeline/screens/splash_screen.dart'; // <-- Menggunakan SplashScreen
import 'package:lifeline/api/firebase_api.dart';
import 'package:intl/date_symbol_data_local.dart'; // <-- Import untuk tanggal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseApi().initNotifications();

  // Inisialisasi untuk format tanggal (ini tetap diperlukan)
  await initializeDateFormatting('id_ID', null);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LifeLine',
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashScreen(), // <-- Menggunakan SplashScreen, bukan AuthGate
      debugShowCheckedModeBanner: false,
    );
  }
}