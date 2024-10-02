import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/auth_service.dart';
import 'deals_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PhoneAuthScreen extends StatefulWidget {
  @override
  _PhoneAuthScreenState createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final AuthService _authService = AuthService();
  String? _verificationId;
  bool _isLoading = false;
  bool _codeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Phone Authentication')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyPhoneNumber,
              child: _isLoading ? CircularProgressIndicator() : Text('Verify Phone Number'),
            ),
            if (_codeSent) ...[
              SizedBox(height: 16),
              TextField(
                controller: _otpController,
                decoration: InputDecoration(labelText: 'OTP'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _signInWithOTP,
                child: Text('Sign In'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _verifyPhoneNumber() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.verifyPhoneNumber(
        _phoneController.text,
        (String verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
            _codeSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification code sent')),
          );
        },
        (String error) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInWithOTP() async {
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification ID is null. Please try again.')),
      );
      return;
    }

    try {
      UserCredential userCredential = await _authService.signInWithOTP(_verificationId!, _otpController.text);
      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Successfully signed in')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => DealsScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
