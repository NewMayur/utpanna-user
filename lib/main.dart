import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:utpanna/screens/home_screen.dart';
import 'screens/deals_screen.dart';
import 'screens/deal_detail_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/phone_auth_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/progress.dart';
import 'screens/crop_selection_screen.dart';
import 'screens/objective_selection_screen.dart';
import 'screens/combo_recommendation_screen.dart';
import 'models/deal.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'utils/constants.dart';

import 'providers/combo_provider.dart';

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
        appId: "1:340480522275:web:a5ee3291e33894978ad996"),
  );
  runApp(MyApp());
}

// stag
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
    return ChangeNotifierProvider(
      create: (context) => ComboBuilderProvider(),
      child: MaterialApp(
        title: 'Utpanna',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: AuthWrapper(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/deals': (context) => const DealsScreen(),
          '/combo/select-crop': (context) => const CropSelectionScreen(),
          '/combo/select-objective': (context) =>
              const ObjectiveSelectionScreen(),
          '/combo/recommendations': (context) =>
              const ComboRecommendationScreen(),
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
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

              if (sessionSnapshot.data == true) {
                // Check for deep links and return appropriate screen
                return FutureBuilder<Widget>(
                  future: _handleDeepLink(context, user!),
                  builder: (context, linkSnapshot) {
                    if (linkSnapshot.connectionState != ConnectionState.done) {
                      return Scaffold(body: circularProgress());
                    }
                    return linkSnapshot.data ?? const HomeScreen();
                  },
                );
              } else {
                return PhoneAuthScreen();
              }
            },
          );
        }
        return Scaffold(body: circularProgress());
      },
    );
  }

  Future<Widget> _handleDeepLink(BuildContext context, User user) async {
    try {
      // For web, check if there's a deal ID in the URL
      final String? currentUrl = Uri.base.toString();

      if (currentUrl != null) {
        final Uri uri = Uri.parse(currentUrl);

        // Check for deal parameter in query or fragment
        String? dealId = uri.queryParameters['deal'];

        if (dealId == null && uri.fragment.isNotEmpty) {
          // Check if fragment contains deal/
          if (uri.fragment.startsWith('deal/')) {
            dealId = uri.fragment.substring(5); // Remove 'deal/'
          }
        }

        if (dealId != null && dealId.isNotEmpty) {
          // Fetch deal details and navigate to deal screen
          final response = await http.get(
            Uri.parse('${Constants.apiUrl}/deal-list/${dealId}'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer ${await _authService.getIdToken()}',
            },
          );

          if (response.statusCode == 200) {
            final dealJson = json.decode(response.body);
            final deal = Deal.fromJson(dealJson);
            // Return the DealDetailScreen widget
            return DealDetailScreen(deal: deal);
          } else {
            // If deal not found, return home screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Deal not found')),
            );
          }
        }
      }
    } catch (e) {
      print('Error handling deep link: $e');
    }

    // Default to home screen
    return const HomeScreen();
  }
}
