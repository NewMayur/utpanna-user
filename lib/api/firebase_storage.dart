import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

import '../utils/firebase_config.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage;

  FirebaseStorageService() : _storage = FirebaseStorage.instance;

  /// Upload product image
  Future<String> uploadProductImage(
    String productId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final storageRef =
          _storage.ref().child('products').child(productId).child(fileName);
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload product image: $e');
    }
  }

  /// Upload crop image
  Future<String> uploadCropImage(
    String cropId,
    Uint8List imageBytes,
    String fileName,
  ) async {
    try {
      final storageRef =
          _storage.ref().child('crops').child(cropId).child(fileName);
      final uploadTask = storageRef.putData(imageBytes);
      final snapshot = await uploadTask;

      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw Exception('Failed to upload crop image: $e');
    }
  }

  /// Delete image from storage
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw Exception('Failed to delete image: $e');
    }
  }

  /// Get image download URL
  Future<String?> getDownloadUrl(String path) async {
    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } catch (e) {
      // Return null if image doesn't exist
      return null;
    }
  }
}
