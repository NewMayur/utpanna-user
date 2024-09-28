import 'package:flutter/material.dart';
// Add these imports
import 'package:poshinda/screens/order_history_screen.dart';
import 'package:poshinda/screens/deals_screen.dart';

class ReviewOrderScreen extends StatelessWidget {
  const ReviewOrderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildDealSummary(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Review and Confirm Order',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {
            // Navigate back to DealsScreen
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DealsScreen()),
            );
          },
          child: const Text('Back to Deal'),
        ),
      ],
    );
  }

  Widget _buildDealSummary(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Deal Summary',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildDealDetails(),
            const SizedBox(height: 16),
            _buildNote(),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Navigate to OrderHistoryScreen
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const OrderHistoryScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Confirm Order'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDealDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.network(
          'https://placehold.co/400x300',
          height: 200,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 16),
        const Text(
          'High-Quality Seeds',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Get the best quality seeds for your crops at affordable prices. These seeds are sourced from trusted suppliers and ensure high yield and disease resistance.',
        ),
        const SizedBox(height: 16),
        const Text(
          'Deal Terms',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        _buildDealTerms(),
      ],
    );
  }

  Widget _buildDealTerms() {
    final terms = [
      'Minimum order quantity: 100 kg',
      'Discount: 20% off for group orders',
      'Delivery time: 7-10 days',
      'Payment method: Online payment',
    ];

    return Column(
      children: terms
          .map((term) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(fontSize: 16)),
                    Expanded(child: Text(term)),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[200],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Note',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Payment will be processed only if the deal is confirmed. You will be notified once the deal reaches the required number of participants.',
          ),
        ],
      ),
    );
  }
}