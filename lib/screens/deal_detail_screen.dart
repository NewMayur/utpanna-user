import 'package:flutter/material.dart';
import '../models/deal.dart';

class DealDetailScreen extends StatelessWidget {
  final Deal deal;

  const DealDetailScreen({Key? key, required this.deal}) : super(key: key);

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
                SizedBox(height: 16),
                _buildDealCard(context),
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
        Text(
          'Deal Details',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Back to Catalog'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDealCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              'https://placehold.co/400x300',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 16),
          Text(
            deal.title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            deal.description,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 16),
          _buildDealInfo(),
          SizedBox(height: 16),
          _buildDealTerms(),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _showParticipateDialog(context),
            child: Text('Participate'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDealInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deal Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _buildInfoItem('Price', '₹${deal.price.toStringAsFixed(2)}'),
        _buildInfoItem('Minimum Participants', '${deal.min_participants}'),
        _buildInfoItem('Current Participants', '${deal.current_participants}'),
        _buildInfoItem('Status', deal.status),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildDealTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deal Terms',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _buildTermItem('Minimum participants: ${deal.min_participants}'),
        _buildTermItem('Current participants: ${deal.current_participants}'),
        _buildTermItem('Status: ${deal.status}'),
        _buildTermItem('Payment method: Online payment'),
      ],
    );
  }

  Widget _buildTermItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.circle, size: 8, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _showParticipateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Participate in Deal'),
          content: Text("You'll be notified once the deal reaches the required number of participants for payment."),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Confirm Participation'),
              onPressed: () {
                Navigator.of(context).pop();
                _showParticipationConfirmation(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _showParticipationConfirmation(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully participated in the deal!'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}