
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

class PromoCodesPage extends StatefulWidget {
  const PromoCodesPage({super.key});

  @override
  State<PromoCodesPage> createState() => _PromoCodesPageState();
}

class _PromoCodesPageState extends State<PromoCodesPage> {
  final TextEditingController _promoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Promo Codes'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _promoController,
              decoration: InputDecoration(
                labelText: 'Enter promo code',
                labelStyle: const TextStyle(color: Colors.white),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.check, color: AppColors.accentGreen),
                  onPressed: _applyPromoCode,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('promoCodes')
                    .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();

                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final promo = snapshot.data!.docs[index];
                      return ListTile(
                        title: Text(promo['code'],
                          style: const TextStyle(color: Colors.white)),
                        subtitle: Text('${promo['discount']}% discount',
                          style: const TextStyle(color: Colors.white54)),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyPromoCode() async {
    if (_promoController.text.isEmpty) return;

    await FirebaseFirestore.instance.collection('promoCodes').add({
      'code': _promoController.text,
      'userId': FirebaseAuth.instance.currentUser?.uid,
      'discount': 20,
      'expiry': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
    });

    _promoController.clear();
  }
}