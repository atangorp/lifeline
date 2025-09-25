import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
// 1. GANTI import HomeScreen menjadi MainLayout
import 'package:lifeline/screens/main_layout.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, required this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _bloodTypeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordObscured = true;
  bool _isLoading = false;

  Future<void> _register() async {
    if (!mounted) return;
    // Validasi tambahan untuk memastikan field tidak kosong
    if (_nameController.text.isEmpty || _bloodTypeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama dan Golongan Darah tidak boleh kosong.')),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
          'nama': _nameController.text.trim(),
          'gol_darah': _bloodTypeController.text.trim().toUpperCase(),
          'email': _emailController.text.trim(),
          'uid': userCredential.user!.uid,
          'tanggal_donor_terakhir': null,
          'poin': 0,
          'level': 'Rekrutan',
          'drs': 10,
        });
      }

      if (mounted) {
        // 2. GANTI tujuan navigasi ke MainLayout()
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const MainLayout(),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi Gagal: ${e.message}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  
  
  @override
  void dispose() {
    _nameController.dispose();
    _bloodTypeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- TAMBAHKAN LOGO DI SINI ---
              Image.asset('assets/images/app_logo.png', height: 120),
              const SizedBox(height: 30),
              // --- BATAS LOGO ---

              Text(
                'Daftar Akun Baru',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Form fields
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bloodTypeController,
                decoration: const InputDecoration(labelText: 'Golongan Darah (Contoh: A+, O-)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                obscureText: _isPasswordObscured,
                decoration: InputDecoration(
                  labelText: 'Password (min. 6 karakter)',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordObscured ? Icons.visibility_off : Icons.visibility),
                    onPressed: () {
                      setState(() { _isPasswordObscured = !_isPasswordObscured; });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _register,
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[800],
                            padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Daftar', style: TextStyle(color: Colors.white)),
                      ),
                    ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // <-- BENAR
                children: [
                  const Text('Sudah punya akun?'),
                  TextButton(
                    onPressed: widget.onTap,
                    child: const Text('Login sekarang'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}