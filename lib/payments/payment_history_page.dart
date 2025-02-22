import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/theme/app_colors.dart';

class PaymentHistoryPage extends StatelessWidget {
  const PaymentHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Payment History'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('payments')
            .where('userId', isEqualTo: user?.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final payment = snapshot.data!.docs[index];
              return ListTile(
                leading: const Icon(Icons.receipt, color: Colors.white),
                title: Text(payment['rideId'],
                  style: const TextStyle(color: Colors.white)),
                subtitle: Text('₹${payment['amount']} • ${payment['date']}',
                  style: const TextStyle(color: Colors.white54)),
                trailing: IconButton(
                  icon: const Icon(Icons.download, color: AppColors.accentGreen),
                  onPressed: () => _downloadInvoice(payment.id),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _downloadInvoice(String paymentId) {
    // Implement invoice download logic
  }
}