// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../utils/constants.dart';

// class AuthService {
//   static const String _baseUrl = Constants.apiUrl;
//   static const String _tokenKey = 'auth_token';

//   Future<String> login(String username, String password) async {
//     print("Sending login request...");
//     final response = await http.post(
//       Uri.parse('$_baseUrl/login'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'username': username, 'password': password}),
//     );

//     print("Received response with status code: ${response.statusCode}");
//     print("Response body: ${response.body}");

//     if (response.statusCode == 200) {
//       final Map<String, dynamic> data = json.decode(response.body);
//       if (data['access_token'] != null) {
//         final token = data['access_token'] as String;
//         await _saveToken(token);
//         return token;
//       } else {
//         throw Exception('Access token is null in the response');
//       }
//     } else {
//       throw Exception('Failed to login. Status code: ${response.statusCode}');
//     }
//   }

//   Future<String> register(String username, String password) async {
//     print("Sending registration request...");
//     final response = await http.post(
//       Uri.parse('$_baseUrl/register'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         'username': username,
//         'password': password,
//       }),
//     );

//     print("Received response with status code: ${response.statusCode}");
//     print("Response body: ${response.body}");

//     if (response.statusCode == 201) {
//       final data = json.decode(response.body);
//       return data['token'];
//     } else {
//       throw Exception('Failed to register');
//     }
//   }

//   Future<void> logout() async {
//     await _deleteToken();
//   }

//   Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_tokenKey);
//   }

//   Future<void> _saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString(_tokenKey, token);
//   }

//   Future<void> _deleteToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_tokenKey);
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:js' as js;
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    if (kIsWeb) {
      // For web platform
      try {
        ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber(
          phoneNumber,
          // RecaptchaVerifier(container: 'recaptcha-container'),
        );
        onCodeSent(confirmationResult.verificationId);
      } catch (e) {
        onError(e.toString());
      }
    } else {
      // For mobile platforms
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onError(e.message ?? 'Verification failed');
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    }
  }

  Future<UserCredential> signInWithOTP(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return await _auth.signInWithCredential(credential);
  }

  Future<void> signIn(PhoneAuthCredential credential) async {
    await _auth.signInWithCredential(credential);
    await _setSessionTimeout();
  }

  Future<void> _setSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(Duration(days: 30));
    await prefs.setString('sessionExpiry', expiryDate.toIso8601String());
  }

  Future<bool> isSessionValid() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryString = prefs.getString('sessionExpiry');
    if (expiryString == null) return false;
    
    final expiry = DateTime.parse(expiryString);
    return DateTime.now().isBefore(expiry);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('sessionExpiry');
  }
}