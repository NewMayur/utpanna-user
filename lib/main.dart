import 'package:flutter/material.dart';
import 'screens/deals_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/phone_auth_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/progress.dart';

//dev
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

//stag
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: FirebaseOptions(
//       apiKey: "AIzaSyC5bkN7NgLCif4beAhYAzsddvHzkLNqIy4",
//       authDomain: "utpanna-stag-197de.firebaseapp.com",
//       projectId: "utpanna-stag-197de",
//       storageBucket: "utpanna-stag-197de.appspot.com",
//       messagingSenderId: "466091422192",
//       appId: "1:466091422192:web:28a92ade7ec36391bbad35",
//       measurementId: "G-N6J4C0XDSB"
//     ),
//   );
//   runApp(MyApp());
// }

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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.white, // or your preferred background color
            body: circularProgress(),
          );
        }

        if (snapshot.connectionState == ConnectionState.active) {
          User? user = snapshot.data;
          if (user == null) {
            return PhoneAuthScreen();
          }
          return FutureBuilder<bool>(
            future: _authService.isSessionValid(),
            builder: (context, sessionSnapshot) {
              // Show loading while checking session
              if (sessionSnapshot.connectionState != ConnectionState.done) {
                return Scaffold(body: circularProgress());
              }
              
              return sessionSnapshot.data == true 
                ? DealsScreen() 
                : PhoneAuthScreen();
            },
          );
        }
        return Scaffold(body: circularProgress());
      },
    );
  }
}