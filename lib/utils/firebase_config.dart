import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    try {
      // Only try to load environment files on non-web platforms
      if (!kIsWeb) {
        try {
          await dotenv.load(fileName: ".env.local");

          // Determine which environment file to load
          if (dotenv.env['FIRESTORE_ENVIRONMENT'] != null) {
            // .env.local is already loaded, check if we should load production
            if (dotenv.env['FIRESTORE_ENVIRONMENT'] == 'prod') {
              await dotenv.load(fileName: ".env.production");
            }
          }

          // Initialize Firebase with environment variables if available
          if (dotenv.env.isNotEmpty && dotenv.env['FIREBASE_API_KEY'] != null) {
            await Firebase.initializeApp(
              options: FirebaseOptions(
                apiKey: dotenv.env['FIREBASE_API_KEY']!,
                authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
                projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
                storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
                messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
                appId: dotenv.env['FIREBASE_APP_ID']!,
                measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID'],
              ),
            );
            return; // Success, exit early
          }
        } catch (e) {
          print('Environment file not found, using embedded config: $e');
        }
      }

      // Fallback to embedded Firebase config (for all platforms)
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDiVSLs3goLrzmndUyLa9Sjp0gs4ovHHhA",
          authDomain: "utpanna-dev.firebaseapp.com",
          projectId: "utpanna-dev",
          storageBucket: "utpanna-dev.appspot.com",
          messagingSenderId: "340480522275",
          appId: "1:340480522275:web:a5ee3291e33894978ad996",
          measurementId: "G-LR9LZGLB4L",
        ),
      );

      print('Firebase initialized successfully');
    } catch (e) {
      throw Exception('Failed to initialize Firebase: $e');
    }
  }

  static bool get isDevelopment => dotenv.env['FIRESTORE_ENVIRONMENT'] == 'dev';

  static bool get isProduction => dotenv.env['FIRESTORE_ENVIRONMENT'] == 'prod';

  static String get projectId => dotenv.env['FIREBASE_PROJECT_ID']!;

  static String get storageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET']!;
}
