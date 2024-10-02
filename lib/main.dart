import 'package:flutter/material.dart';
import 'screens/deals_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/phone_auth_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyDiVSLs3goLrzmndUyLa9Sjp0gs4ovHHhA",
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
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _authService.isSessionValid(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.data == true) {
            return DealsScreen();
          } else {
            return PhoneAuthScreen();
          }
        }
      },
    );
  }
}