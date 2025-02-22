import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/theme/app_colors.dart';

class PreviousRidesPage extends StatelessWidget {
  const PreviousRidesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Ride History', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: AppColors.errorRed),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No rides found',
                style: TextStyle(color: AppColors.primaryWhite, fontSize: 18),
              ),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final rides = userData['rides'] as List<dynamic>? ?? [];

          if (rides.isEmpty) {
            return const Center(
              child: Text(
                'No rides found',
                style: TextStyle(color: AppColors.primaryWhite, fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              final pickup = ride['pickup'] as GeoPoint;
              final destination = ride['destination'] as GeoPoint;
              final fare = ride['fare'] as double;
              final rideType = ride['rideType'] as String;
              final status = ride['status'] as String;
              final createdAt = (ride['createdAt'] as Timestamp).toDate();
              final isCompleted = status == 'completed';

              return Card(
                color: AppColors.secondaryDark,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  title: Text(
                    'Ride Type: $rideType',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fare: ₹${fare.toStringAsFixed(2)}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        'Pickup: (${pickup.latitude.toStringAsFixed(3)}, ${pickup.longitude.toStringAsFixed(3)})',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        'Destination: (${destination.latitude.toStringAsFixed(3)}, ${destination.longitude.toStringAsFixed(3)})',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        'Date: ${createdAt.day}/${createdAt.month}/${createdAt.year}',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      Text(
                        'Status: ${isCompleted ? 'Completed' : 'Upcoming'}',
                        style: TextStyle(
                          color: isCompleted 
                              ? AppColors.accentGreen 
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  trailing: !isCompleted
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: AppColors.errorRed),
                          onPressed: () => _cancelRide(context, ride['rideId']),
                        )
                      : null, // Hide cancel button for completed rides
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _cancelRide(BuildContext context, String rideId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Remove the ride from the user's document
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'rides': FieldValue.arrayRemove([
          {
            'rideId': rideId,
          }
        ]),
      });

      // Update the ride status in the 'rides' collection
      await FirebaseFirestore.instance.collection('rides').doc(rideId).update({
        'status': 'cancelled',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ride cancelled successfully'),
          backgroundColor: AppColors.accentGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel ride'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }
}