import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:lifeline/screens/dashboard_screen.dart';
import 'package:lifeline/screens/events_screen.dart';
import 'package:lifeline/screens/profile_screen.dart';
import 'package:lifeline/screens/requests_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _selectedIndex = 0;
  // Variabel untuk menyimpan data user yang sedang login
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    // Ambil data user saat halaman ini pertama kali dimuat
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // Buat daftar halaman di dalam build agar bisa mengakses _currentUser
  late final List<Widget> _pages = [
    // Kirim data user ke DashboardScreen dan ProfileScreen
    DashboardScreen(currentUser: _currentUser),
    const RequestsScreen(),
    const EventsScreen(),
    ProfileScreen(currentUser: _currentUser),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.red[800],
        unselectedItemColor: Colors.grey[600],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.bloodtype_outlined), activeIcon: Icon(Icons.bloodtype), label: 'Kebutuhan'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined), activeIcon: Icon(Icons.event), label: 'Event'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}