// send_parcel_page.dart
import 'package:flutter/material.dart';

class SendParcelPage extends StatelessWidget {
  const SendParcelPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Send Parcel')),
      body: const Center(
        child: Text(
          'This is the Send Parcel page.',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
