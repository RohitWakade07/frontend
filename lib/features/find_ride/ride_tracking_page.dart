
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../core/theme/app_colors.dart';

class RideTrackingPage extends StatelessWidget {
  const RideTrackingPage({super.key, required LatLng pickup, required LatLng destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Column(
        children: [
          AppBar(
            title: const Text('Tracking Ride'),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          Expanded(
            child: Stack(
              children: [
                const GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(19.0760, 72.8777),
                    zoom: 14,
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    color: AppColors.secondaryDark,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const ListTile(
                            leading: Icon(Icons.timer, color: Colors.white),
                            title: Text('Arriving in 5 mins',
                              style: TextStyle(color: Colors.white)),
                          ),
                          LinearProgressIndicator(
                            value: 0.4,
                            backgroundColor: Colors.grey[800],
                            color: AppColors.accentGreen,
                          ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accentGreen,
                            ),
                            child: const Text('Cancel Ride',
                              style: TextStyle(color: Colors.black)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}