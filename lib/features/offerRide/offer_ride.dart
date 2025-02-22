import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/theme/app_colors.dart';

class OfferRidePage extends StatefulWidget {
  const OfferRidePage({super.key});

  @override
  _OfferRidePageState createState() => _OfferRidePageState();
}

class _OfferRidePageState extends State<OfferRidePage> {
  final TextEditingController _pickupController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _fareController = TextEditingController();
  final TextEditingController _seatsController = TextEditingController();
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Offer a Ride', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLocationField(
              controller: _pickupController,
              hintText: 'Enter pickup location',
              icon: Icons.location_on,
              onTap: () async {
                // Open a map or location picker to select pickup location
                final location = await _selectLocation(context);
                if (location != null) {
                  setState(() => _pickupLocation = location);
                  _pickupController.text =
                      '${location.latitude}, ${location.longitude}';
                }
              },
            ),
            const SizedBox(height: 10),
            _buildLocationField(
              controller: _destinationController,
              hintText: 'Enter destination',
              icon: Icons.flag,
              onTap: () async {
                // Open a map or location picker to select destination location
                final location = await _selectLocation(context);
                if (location != null) {
                  setState(() => _destinationLocation = location);
                  _destinationController.text =
                      '${location.latitude}, ${location.longitude}';
                }
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _fareController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryDark,
                hintText: 'Enter fare',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _seatsController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryDark,
                hintText: 'Enter available seats',
                hintStyle: const TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _offerRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text(
                      'Offer Ride',
                      style: TextStyle(color: Colors.black, fontSize: 18),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.secondaryDark,
        prefixIcon: Icon(icon, color: Colors.white54),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      style: const TextStyle(color: Colors.white),
      readOnly: true,
      onTap: onTap,
    );
  }

  Future<LatLng?> _selectLocation(BuildContext context) async {
    // Implement a map or location picker here
    // For now, return a dummy location
    return const LatLng(19.0760, 72.8777); // Mumbai coordinates
  }

  Future<void> _offerRide() async {
    if (_pickupLocation == null || _destinationLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select pickup and destination locations')),
      );
      return;
    }

    if (_fareController.text.isEmpty || _seatsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter fare and available seats')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not authenticated')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final rideData = {
      'driverId': user.uid,
      'pickup': GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
      'destination': GeoPoint(
          _destinationLocation!.latitude, _destinationLocation!.longitude),
      'fare': double.parse(_fareController.text),
      'seats': int.parse(_seatsController.text),
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
      'passengers': [], // List of passengers who booked the ride
    };

    try {
      await FirebaseFirestore.instance.collection('rides').add(rideData);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride offered successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
      Navigator.pop(context); // Go back after offering the ride
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to offer ride'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}