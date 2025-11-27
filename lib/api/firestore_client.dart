import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../utils/firebase_config.dart';

class FirestoreClient {
  static FirebaseFirestore? _firestore;

  /// Initialize Firestore instance
  static FirebaseFirestore get firestore {
    if (_firestore == null) {
      _firestore = FirebaseFirestore.instanceFor(
        app: Firebase.app(),
      );

      // Configure settings for offline persistence
      _firestore!.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
    }
    return _firestore!;
  }

  /// Execute Firestore operations with error handling
  static Future<T> executeOperation<T>(
    Future<T> Function() operation, {
    String? operationName,
  }) async {
    try {
      return await operation();
    } on FirebaseException catch (e) {
      final errorMessage = _parseFirebaseError(e);
      final operationDesc = operationName != null ? ' for $operationName' : '';
      throw FirestoreException(
        'Firestore operation failed$operationDesc: $errorMessage',
        code: e.code,
        details: e.message,
      );
    } catch (e) {
      throw FirestoreException('Unexpected error: $e');
    }
  }

  /// Execute Firestore transactions
  static Future<T> executeTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    return await firestore.runTransaction(
      (transaction) => executeOperation(
        () => transactionHandler(transaction),
        operationName: 'transaction',
      ),
    );
  }

  /// Parse Firebase error codes into user-friendly messages
  static String _parseFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Access denied. Please check your permissions.';
      case 'not-found':
        return 'Document not found.';
      case 'already-exists':
        return 'Document already exists.';
      case 'unavailable':
        return 'Service is currently unavailable. Please try again later.';
      case 'deadline-exceeded':
        return 'Request timed out. Please try again.';
      case 'resource-exhausted':
        return 'Too many requests. Please slow down.';
      case 'failed-precondition':
        return 'Operation could not be completed due to current state.';
      case 'aborted':
        return 'Operation was aborted. Please try again.';
      case 'out-of-range':
        return 'Invalid data range specified.';
      case 'unimplemented':
        return 'This feature is not implemented yet.';
      case 'internal':
      case 'unknown':
      default:
        return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Close the Firestore instance (mainly for testing)
  static void dispose() {
    _firestore = null;
  }
}

/// Custom exception for Firestore operations
class FirestoreException implements Exception {
  final String message;
  final String? code;
  final String? details;

  FirestoreException(this.message, {this.code, this.details});

  @override
  String toString() {
    return 'FirestoreException: $message${code != null ? ' (Code: $code)' : ''}';
  }
}
