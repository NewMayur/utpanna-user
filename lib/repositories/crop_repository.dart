import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/farming_models.dart';

class CropRepository {
  final FirestoreClient _client;

  CropRepository(this._client);

  /// Get all crops
  Future<List<Crop>> getAllCrops() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot =
          await FirestoreCollections.cropsRef.orderBy('name').get();

      return snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();
    });
  }

  /// Watch all crops (real-time)
  Stream<List<Crop>> watchAllCrops() {
    return FirestoreCollections.cropsRef.orderBy('name').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList());
  }

  /// Get crop by ID
  Future<Crop?> getCropById(String cropId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.cropDoc(cropId).get();
      return doc.exists ? Crop.fromFirestore(doc) : null;
    });
  }

  /// Watch crop by ID (real-time)
  Stream<Crop?> watchCropById(String cropId) {
    return FirestoreCollections.cropDoc(cropId)
        .snapshots()
        .map((doc) => doc.exists ? Crop.fromFirestore(doc) : null);
  }

  /// Create new crop
  Future<void> createCrop(Crop crop) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.cropDoc(crop.id).set({
        ...crop.toFirestore(),
        'createdAt': Timestamp.now(),
      });
    });
  }

  /// Update crop
  Future<void> updateCrop(String cropId, Map<String, dynamic> updates) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.cropDoc(cropId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete crop
  Future<void> deleteCrop(String cropId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.cropDoc(cropId).delete();
    });
  }

  /// Search crops by name
  Future<List<Crop>> searchCrops(String query) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.cropsRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => Crop.fromFirestore(doc)).toList();
    });
  }
}
