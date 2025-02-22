import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../core/theme/app_colors.dart';
import '../features/find_ride/ride_tracking_page.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  String _selectedPaymentMethod = 'upi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RadioListTile(
              title: const Text('UPI',
                style: TextStyle(color: Colors.white)),
              value: 'upi',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              activeColor: AppColors.accentGreen,
            ),
            RadioListTile(
              title: const Text('Credit/Debit Card',
                style: TextStyle(color: Colors.white)),
              value: 'card',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              activeColor: AppColors.accentGreen,
            ),
            RadioListTile(
              title: const Text('Wallet',
                style: TextStyle(color: Colors.white)),
              value: 'wallet',
              groupValue: _selectedPaymentMethod,
              onChanged: (value) => setState(() => _selectedPaymentMethod = value!),
              activeColor: AppColors.accentGreen,
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const RideTrackingPage(
                  pickup: LatLng(0, 0),
                  destination: LatLng(0, 0),
                ))),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentGreen,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Confirm Payment',
                style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      ),
    );
  }
}