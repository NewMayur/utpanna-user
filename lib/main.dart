import 'package:flutter/material.dart';
import 'screens/deals_screen.dart';
import 'screens/login_screen.dart'; // Add this import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "not found",
      authDomain: "utpanna-dev.firebaseapp.com",
      projectId: "utpanna-dev",
      storageBucket: "utpanna-dev.appspot.com",
      messagingSenderId: "340480522275",
      appId: "1:340480522275:web:a5ee3291e33894978ad996"
    ),
  );
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