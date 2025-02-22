import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart'; // For distance calculation
import '../../core/theme/app_colors.dart';
import 'ride_confirmed_page.dart'; // Import the RideConfirmedPage

class CreateRidePage extends StatefulWidget {
  final String rideType;
  const CreateRidePage({super.key, this.rideType = 'car'});

  @override
  State<CreateRidePage> createState() => _CreateRidePageState();
}

class _CreateRidePageState extends State<CreateRidePage> {
  late GoogleMapController _mapController;
  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  double _fareEstimate = 0.0;
  String _selectedRideType = 'Standard';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _rideTypes = [
    {
      'name': 'Standard',
      'icon': Icons.directions_car,
      'pricePerKm': 12.0,
      'eta': '5 min',
      'seats': 4
    },
    {
      'name': 'Premium',
      'icon': Icons.airline_seat_recline_extra,
      'pricePerKm': 18.0,
      'eta': '7 min',
      'seats': 4
    },
    {
      'name': 'XL',
      'icon': Icons.airport_shuttle,
      'pricePerKm': 25.0,
      'eta': '10 min',
      'seats': 6
    },
    {
      'name': 'Bike',
      'icon': Icons.directions_bike,
      'pricePerKm': 8.0, // Lower price per km for bikes
      'eta': '3 min', // Faster ETA for bikes
      'seats': 1 // Only one seat for bikes
    },
  ];

  @override
  void initState() {
    super.initState();
    // Set the initial ride type based on the widget.rideType parameter
    _selectedRideType = widget.rideType == 'bike' ? 'Bike' : 'Standard';
  }

  // Function to calculate distance between two LatLng points
  Future<double> _calculateDistance(LatLng start, LatLng end) async {
    return Geolocator.distanceBetween(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        ) /
        1000; // Convert meters to kilometers
  }

  // Function to update fare based on distance and ride type
  Future<void> _updateFare() async {
    if (_pickupLocation == null || _destinationLocation == null) return;

    final distance =
        await _calculateDistance(_pickupLocation!, _destinationLocation!);
    final selectedType =
        _rideTypes.firstWhere((type) => type['name'] == _selectedRideType);
    setState(() => _fareEstimate = distance * selectedType['pricePerKm']);
  }

  // Function to confirm the ride
  Future<void> _confirmRide() async {
  if (_pickupLocation == null || _destinationLocation == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select pickup and destination locations')),
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
    'userId': user.uid,
    'pickup': GeoPoint(_pickupLocation!.latitude, _pickupLocation!.longitude),
    'destination': GeoPoint(
        _destinationLocation!.latitude, _destinationLocation!.longitude),
    'fare': _fareEstimate,
    'rideType': _selectedRideType,
    'status': 'searching',
    'createdAt': FieldValue.serverTimestamp(), // Use serverTimestamp here
    'driverId': null,
    'estimatedArrival': DateTime.now().add(const Duration(minutes: 5)),
  };

  try {
    // Add the ride to the 'rides' collection
    final docRef =
        await FirebaseFirestore.instance.collection('rides').add(rideData);

    // Check if the user's document exists
    final userDocRef =
        FirebaseFirestore.instance.collection('users').doc(user.uid);

    final userDoc = await userDocRef.get();

    // If the document does not exist, create it with the ride data
    if (!userDoc.exists) {
      await userDocRef.set({
        'email': user.email,
        'phone': user.phoneNumber,
        'name': user.displayName ?? 'User',
        'rides': [
          {
            'rideId': docRef.id,
            'pickup': rideData['pickup'],
            'destination': rideData['destination'],
            'fare': rideData['fare'],
            'rideType': rideData['rideType'],
            'status': rideData['status'],
            'createdAt': DateTime.now(), // Use DateTime.now() instead of serverTimestamp
          }
        ],
      });
    } else {
      // If the document exists, update it with the new ride
      await userDocRef.update({
        'rides': FieldValue.arrayUnion([
          {
            'rideId': docRef.id,
            'pickup': rideData['pickup'],
            'destination': rideData['destination'],
            'fare': rideData['fare'],
            'rideType': rideData['rideType'],
            'status': rideData['status'],
            'createdAt': DateTime.now(), // Use DateTime.now() instead of serverTimestamp
          }
        ]),
      });
    }

    // Navigate to RideConfirmedPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RideConfirmedPage(
          rideId: docRef.id,
          rideData: rideData,
          pickup: _pickupLocation,
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create ride: $e')),
    );
    debugPrint('Error creating ride: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
  // Function to build location card
  Widget _buildLocationCard(String title, IconData icon, VoidCallback onTap) {
    return Card(
      color: AppColors.secondaryDark,
      child: ListTile(
        leading: Icon(icon, color: AppColors.accentGreen),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.edit, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }

  // Function to build ride type selector
  Widget _buildRideTypeSelector() {
    return Column(
      children: _rideTypes
          .map((type) => RadioListTile(
                title: Row(
                  children: [
                    Icon(type['icon'], color: AppColors.accentGreen),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(type['name'],
                            style: const TextStyle(color: Colors.white)),
                        Text(
                            "₹${type['pricePerKm']}/km • ${type['seats']} seat${type['seats'] > 1 ? 's' : ''}",
                            style: TextStyle(color: Colors.grey[400])),
                      ],
                    ),
                  ],
                ),
                value: type['name'],
                groupValue: _selectedRideType,
                onChanged: (value) {
                  setState(() => _selectedRideType = value!);
                  _updateFare();
                },
                activeColor: AppColors.accentGreen,
              ))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('New Ride'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(19.0760, 72.8777),
                zoom: 12,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: {
                if (_pickupLocation != null)
                  Marker(
                    markerId: const MarkerId('pickup'),
                    position: _pickupLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueGreen),
                  ),
                if (_destinationLocation != null)
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: _destinationLocation!,
                    icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueRed),
                  ),
              },
              onTap: (LatLng location) {
                if (_pickupLocation == null) {
                  setState(() => _pickupLocation = location);
                } else if (_destinationLocation == null) {
                  setState(() => _destinationLocation = location);
                } else {
                  setState(() {
                    _pickupLocation = location;
                    _destinationLocation = null;
                  });
                }
                _updateFare();
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildLocationCard(
                  _pickupLocation == null
                      ? 'Pickup Location'
                      : 'Pickup Selected',
                  Icons.location_on,
                  () {
                    setState(() => _pickupLocation = null);
                    _updateFare();
                  },
                ),
                const SizedBox(height: 10),
                _buildLocationCard(
                  _destinationLocation == null
                      ? 'Destination'
                      : 'Destination Selected',
                  Icons.flag,
                  () {
                    setState(() => _destinationLocation = null);
                    _updateFare();
                  },
                ),
                const Divider(color: Colors.white24),
                _buildRideTypeSelector(),
                const Divider(color: Colors.white24),
                ListTile(
                  title: const Text('Estimated Fare',
                      style: TextStyle(color: Colors.white)),
                  trailing: Text('₹${_fareEstimate.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: AppColors.accentGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed:
                      _pickupLocation != null && _destinationLocation != null
                          ? _confirmRide
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentGreen,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text('Confirm Ride',
                          style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}