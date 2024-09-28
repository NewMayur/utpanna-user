import 'package:flutter/material.dart';
import 'screens/deals_screen.dart';
import 'screens/login_screen.dart'; // Add this import

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Utpanna',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/': (context) => LoginScreen(),
        // Add other routes here
      },
    );
  }
}