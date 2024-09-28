import 'package:flutter/material.dart';

class StartScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Farmer Group Buy', style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Open App'),
              onPressed: () => Navigator.pushNamed(context, '/login'),
            ),
          ],
        ),
      ),
    );
  }
}