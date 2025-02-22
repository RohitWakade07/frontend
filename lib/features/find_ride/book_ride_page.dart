import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/theme/app_colors.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookRidePage extends StatefulWidget {
  const BookRidePage({super.key});

  @override
  _BookRidePageState createState() => _BookRidePageState();
}

class _BookRidePageState extends State<BookRidePage> {
  late Position _currentPosition;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = position;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Book a Ride', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.accentGreen))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('rides')
                  .where('status', isEqualTo: 'available')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: AppColors.errorRed),
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'No rides available',
                      style: TextStyle(color: AppColors.primaryWhite, fontSize: 18),
                    ),
                  );
                }

                final rides = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final ride = rides[index];
                    final pickup = ride['pickup'] as GeoPoint;
                    final destination = ride['destination'] as GeoPoint;
                    final fare = ride['fare'] as double;
                    final seats = ride['seats'] as int;

                    // Calculate distance between current location and pickup location
                    final distance = Geolocator.distanceBetween(
                      _currentPosition.latitude,
                      _currentPosition.longitude,
                      pickup.latitude,
                      pickup.longitude,
                    );

                    return Card(
                      color: AppColors.secondaryDark,
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ListTile(
                        title: Text(
                          'Fare: ₹${fare.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup: (${pickup.latitude.toStringAsFixed(3)}, ${pickup.longitude.toStringAsFixed(3)})',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              'Destination: (${destination.latitude.toStringAsFixed(3)}, ${destination.longitude.toStringAsFixed(3)})',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              'Distance: ${(distance / 1000).toStringAsFixed(2)} km',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              'Seats available: $seats',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () => _bookRide(ride.id),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentGreen,
                          ),
                          child: const Text(
                            'Book',
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _bookRide(String rideId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'passengers': FieldValue.arrayUnion([user.email]),
        'seats': FieldValue.increment(-1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride booked successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to book ride'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}