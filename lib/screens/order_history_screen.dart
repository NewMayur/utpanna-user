import 'package:flutter/material.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

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
                _buildOrderList(),
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
          'Order History',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // Go back to the previous screen
          },
          child: const Text('Back to Dashboard'),
        ),
      ],
    );
  }

  Widget _buildOrderList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Orders',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildOrderItem(
              'High-Quality Seeds',
              'Delivered',
              '12345',
              '100 kg',
              '2023-01-15',
              Colors.green,
            ),
            const SizedBox(height: 16),
            _buildOrderItem(
              'Organic Fertilizers',
              'In Transit',
              '12346',
              '50 kg',
              '2023-01-20',
              Colors.yellow,
            ),
            const SizedBox(height: 16),
            _buildOrderItem(
              'Effective Pesticides',
              'Pending',
              '12347',
              '30 kg',
              '2023-01-25',
              Colors.red,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement contact support functionality
              },
              child: const Text('Contact Support'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(String title, String status, String orderId, String quantity, String orderDate, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                status,
                style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Order ID: $orderId'),
          Text('Quantity: $quantity'),
          Text('Order Date: $orderDate'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement order tracking functionality
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Track Order'),
          ),
        ],
      ),
    );
  }
}