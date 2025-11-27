import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:utpanna/screens/home_screen.dart';
import 'screens/deals_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/phone_auth_screen.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'widgets/progress.dart';
import 'screens/crop_selection_screen.dart';
import 'screens/objective_selection_screen.dart';
import 'screens/combo_recommendation_screen.dart';

import 'providers/combo_provider.dart';
import 'providers/deal_provider.dart';
import 'providers/alternative_provider.dart';
import 'utils/firebase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ComboBuilderProvider()),
        ChangeNotifierProvider(create: (context) => DealProvider()),
        ChangeNotifierProvider(create: (context) => AlternativeProvider()),
      ],
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
                  ? const HomeScreen()
                  : PhoneAuthScreen();
            },
          );
        }
        return Scaffold(body: circularProgress());
      },
    );
  }
}
