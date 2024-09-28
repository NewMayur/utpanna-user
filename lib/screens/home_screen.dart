import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          ElevatedButton(
            child: const Text('Login'),
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 1,
                  childAspectRatio: 1.5,
                  mainAxisSpacing: 16,
                  children: [
                    _buildCard(
                      icon: Icons.local_offer,
                      title: 'Browse Deals',
                      description: 'Explore the latest deals on agricultural inputs and more.',
                      buttonText: 'Go to Deals',
                      color: Colors.blue,
                    ),
                    _buildCard(
                      icon: Icons.group,
                      title: 'Manage Groups',
                      description: 'Create and manage your farming groups for collective buying.',
                      buttonText: 'Manage Groups',
                      color: Colors.green,
                    ),
                    _buildCard(
                      icon: Icons.inventory,
                      title: 'View Orders',
                      description: 'Track your orders and receive real-time updates.',
                      buttonText: 'View Orders',
                      color: Colors.amber,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: color),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }
}
