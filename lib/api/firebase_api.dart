import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseApi {
  // 1. Buat instance dari Firebase Messaging
  final _firebaseMessaging = FirebaseMessaging.instance;

  // 2. Fungsi untuk menginisialisasi notifikasi
  Future<void> initNotifications() async {
    // Minta izin dari pengguna (akan kita lengkapi nanti)
    await _firebaseMessaging.requestPermission();

    // Ambil FCM Token untuk perangkat ini
    final fcmToken = await _firebaseMessaging.getToken();

    // Cetak token (ini penting untuk testing nanti!)
    print('FCM Token: $fcmToken');
  }
}