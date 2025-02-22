import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideConfirmedPage extends StatelessWidget {
  final String rideId; // Unique ID of the ride
  final Map<String, dynamic> rideData; // Ride details
  final LatLng? pickup; // Pickup location

  const RideConfirmedPage({
    super.key,
    required this.rideId,
    required this.rideData,
    this.pickup,
  });

  void _cancelRide(BuildContext context) async {
    await FirebaseFirestore.instance.collection('rides').doc(rideId).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final GeoPoint pickupGeo = rideData['pickup'] as GeoPoint;
    final GeoPoint destinationGeo = rideData['destination'] as GeoPoint;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack, // Match HomePage background
      appBar: AppBar(
        title: const Text('Ride Confirmed', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondaryDark, // Match HomePage app bar
        iconTheme: const IconThemeData(color: Colors.white), // White back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Map Section
            SizedBox(
              height: 200,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(pickupGeo.latitude, pickupGeo.longitude),
                  zoom: 14,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: LatLng(pickupGeo.latitude, pickupGeo.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position:
                        LatLng(destinationGeo.latitude, destinationGeo.longitude),
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
                },
              ),
            ),
            const SizedBox(height: 20),
            // Ride Details
            Text('Fare: ₹${rideData['fare'].toStringAsFixed(2)}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Ride Type: ${rideData['rideType']}',
                style: TextStyle(color: Colors.grey[400])),
            const SizedBox(height: 20),
            // Driver Info
            const Text('Your Driver',
                style: TextStyle(color: Colors.white, fontSize: 16)),
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: NetworkImage('https://i.pravatar.cc/100'),
              ),
              title: const Text('John Driver',
                  style: TextStyle(color: Colors.white)),
              subtitle: RatingStars(
                value: 4.5,
                starBuilder: (index, color) => Icon(
                  Icons.star,
                  color: color,
                ),
                starCount: 5,
                starSize: 20,
                valueLabelColor: const Color(0xff9b9b9b),
                valueLabelTextStyle: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontStyle: FontStyle.normal,
                    fontSize: 12.0),
                starSpacing: 2,
                maxValue: 5,
                starOffColor: const Color(0xffe7e8ea),
                starColor: AppColors.accentGreen, // Match HomePage accent color
              ),
            ),
            const Spacer(),
            // Cancel Button
            ElevatedButton(
              onPressed: () => _cancelRide(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Red for cancel action
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                ),
              ),
              child: const Text('Cancel Ride',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}