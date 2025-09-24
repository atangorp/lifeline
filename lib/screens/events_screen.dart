import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Jangan lupa import intl
import 'event_detail_screen.dart';
import 'dart:async';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-2.5489, 118.0149), // Posisi tengah Indonesia
    zoom: 4.5,
  );
    Future<void> _goToLocation(GeoPoint location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 15.0, // Zoom lebih dekat untuk fokus
      ),
    ));
  }
    // Fungsi untuk menggerakkan kamera peta ke lokasi tertentu
  Future<void> _goToLocation(GeoPoint location) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
        target: LatLng(location.latitude, location.longitude),
        zoom: 14.0, // Zoom lebih dekat
      ),
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peta Event Donor Darah'),
        backgroundColor: Colors.red[800],
        foregroundColor: Colors.white,
      ),
// Ganti seluruh body dengan ini
body: StreamBuilder<QuerySnapshot>(
  stream: FirebaseFirestore.instance
      .collection('events')
      .orderBy('tanggal', descending: false)
      .snapshots(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
      return const Center(child: Text('Belum ada event donor darah.'));
    }

    final events = snapshot.data!.docs;

    // Buat set untuk menampung semua pin (marker)
    final Set<Marker> markers = {};
    for (var doc in events) {
      final data = doc.data() as Map<String, dynamic>;
      final GeoPoint? geoPoint = data['lokasi_koordinat'];

      if (geoPoint != null) {
        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
            infoWindow: InfoWindow(
              title: data['nama_event'],
              snippet: data['lokasi'],
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        // Bagian Peta
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4, // 40% dari tinggi layar
          child: GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: _initialPosition,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
            },
            markers: markers, // Tampilkan semua pin di peta
          ),
        ),

        // Bagian Daftar di Bawah Peta
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(10.0),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final doc = events[index];
              final data = doc.data() as Map<String, dynamic>;

              // Ambil dan format data tanggal
              final Timestamp timestamp = data['tanggal'] ?? Timestamp.now();
              final DateTime date = timestamp.toDate();
              final String formattedDate = DateFormat('dd MMMM yyyy').format(date);

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => EventDetailScreen(eventData: data),
                    ),
                  );
                },
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['nama_event'] ?? 'Tanpa Nama Event',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Text(formattedDate),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 16, color: Colors.grey[700]),
                            const SizedBox(width: 8),
                            Expanded(child: Text(data['lokasi'] ?? 'Tanpa Lokasi')),
                          ],
                        ),
                        const Divider(height: 20),
                        Text(data['deskripsi'] ?? ''),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  },
),
    );
  }
}