import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class EventDetailScreen extends StatelessWidget {
  // Halaman ini akan menerima data event dalam format Map
  final Map<String, dynamic> eventData;

  const EventDetailScreen({super.key, required this.eventData});

  @override
  Widget build(BuildContext context) {
    // Ambil dan format data tanggal
    final Timestamp timestamp = eventData['tanggal'] ?? Timestamp.now();
    final DateTime date = timestamp.toDate();
    final String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(date);
    final String formattedTime = DateFormat('HH:mm').format(date);

    return Scaffold(
      appBar: AppBar(
        title: Text(eventData['nama_event'] ?? 'Detail Event'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Event
            Text(
              eventData['nama_event'] ?? 'Tanpa Nama Event',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Penyelenggara
            Text(
              'Diselenggarakan oleh: ${eventData['penyelenggara'] ?? 'Tidak diketahui'}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(height: 30),

            // Detail Waktu & Tempat
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.red),
              title: const Text('Tanggal'),
              subtitle: Text(formattedDate),
            ),
            ListTile(
              leading: const Icon(Icons.access_time, color: Colors.red),
              title: const Text('Waktu'),
              subtitle: Text('$formattedTime WIB'),
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Lokasi'),
              subtitle: Text(eventData['lokasi'] ?? 'Tanpa Lokasi'),
            ),
            const Divider(height: 30),

            // Deskripsi
            Text(
              'Deskripsi Event',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              eventData['deskripsi'] ?? 'Tidak ada deskripsi.',
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}