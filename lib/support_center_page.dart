import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'core/theme/app_colors.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'How to cancel a ride?',
      'answer': 'Open your rides history, select the active ride, and tap "Cancel Ride".',
      'icon': Icons.cancel,
    },
    {
      'question': 'Payment issues',
      'answer': 'Check your payment method in profile settings or contact our support team.',
      'icon': Icons.payment,
    },
    {
      'question': 'Safety concerns',
      'answer': 'Use the emergency button in the app or contact local authorities immediately.',
      'icon': Icons.security,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        title: const Text('Support Center'),
        backgroundColor: AppColors.secondaryDark,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _faqs.length,
                separatorBuilder: (context, index) => Divider(color: Colors.grey[800]),
                itemBuilder: (context, index) => ExpansionTile(
                  leading: Icon(_faqs[index]['icon'], color: AppColors.accentGreen),
                  title: Text(
                    _faqs[index]['question'],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      child: Text(
                        _faqs[index]['answer'],
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.secondaryDark,
                hintText: 'Describe your issue...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _buildSubmitButton(),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              minLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return _isSubmitting
        ? const Padding(
            padding: EdgeInsets.all(12),
            child: CircularProgressIndicator(color: AppColors.accentGreen),
          )
        : IconButton(
            icon: const Icon(Icons.send, color: AppColors.accentGreen),
            onPressed: _submitSupportRequest,
            tooltip: 'Send Support Request',
          );
  }

  Future<void> _submitSupportRequest() async {
    if (_messageController.text.isEmpty) {
      _showSnackBar('Please enter your message before submitting');
      return;
    }

    setState(() => _isSubmitting = true);
    
    try {
      await FirebaseFirestore.instance.collection('supportTickets').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'email': FirebaseAuth.instance.currentUser?.email,
        'message': _messageController.text,
        'status': 'open',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      _showSnackBar('Support request submitted successfully!');
    } catch (e) {
      _showSnackBar('Failed to submit request: ${e.toString()}');
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  void _showSnackBar(String message) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.accentGreen,
          duration: const Duration(seconds: 2),
        ),
      );
    });
  }
}