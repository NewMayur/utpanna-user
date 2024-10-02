import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> getIdToken() async {
  User? user = _auth.currentUser;
    if (user != null) {
      return await user.getIdToken();
    }
    return null;
  }

  Future<void> verifyPhoneNumber(
    String phoneNumber,
    Function(String) onCodeSent,
    Function(String) onError,
  ) async {
    if (kIsWeb) {
      try {
        ConfirmationResult confirmationResult = await _auth.signInWithPhoneNumber(phoneNumber);
        onCodeSent(confirmationResult.verificationId);
      } catch (e) {
        onError(e.toString());
      }
    } else {
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
    UserCredential userCredential = await _auth.signInWithCredential(credential);
    await _setSessionTimeout();
    return userCredential;
  }

  Future<void> _setSessionTimeout() async {
    final prefs = await SharedPreferences.getInstance();
    final expiryDate = DateTime.now().add(Duration(days: 30));
    await prefs.setString('sessionExpiry', expiryDate.toIso8601String());
  }

  Future<bool> isSessionValid() async {
    if (_auth.currentUser == null) {
      return false;
    }
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