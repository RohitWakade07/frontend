import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FindRidePage extends StatefulWidget {
  final String destination;  // Add this parameter

  const FindRidePage({
    super.key,
    required this.destination,  // Make it required
  });

  @override
  _FindRidePageState createState() => _FindRidePageState();
}

class _FindRidePageState extends State<FindRidePage> {
  final Location _location = Location();
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          _showError('Location services are disabled');
          return;
        }
      }

      // Check for location permission
      PermissionStatus permissionStatus = await _location.hasPermission();
      if (permissionStatus == PermissionStatus.denied) {
        permissionStatus = await _location.requestPermission();
        if (permissionStatus != PermissionStatus.granted) {
          _showError('Location permissions denied');
          return;
        }
      }

      // Fetch location
      LocationData currentLocation = await _location.getLocation();
      if (currentLocation.latitude == null || currentLocation.longitude == null) {
        throw Exception('Invalid location data');
      }

      // Update state
      setState(() {
        _currentLocation = LatLng(
          currentLocation.latitude!,
          currentLocation.longitude!,
        );
        _isLoading = false;
      });

      // Move camera to location
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15),
      );
    } catch (e) {
      _showError('Error fetching location: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Set<Marker> _createMarkers() {
    return _currentLocation == null
        ? {}
        : {
      Marker(
        markerId: const MarkerId('currentLocation'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride to ${widget.destination}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? const LatLng(37.7749, -122.4194), // SF as fallback
              zoom: 15,
            ),
            onMapCreated: (controller) => _mapController = controller,
            markers: _createMarkers(),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getLocation,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}
