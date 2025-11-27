import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/farming_models.dart';

class RecommendationRepository {
  final FirestoreClient _client;

  RecommendationRepository(this._client);

  /// Get all recommendations
  Future<List<Recommendation>> getAllRecommendations() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef.get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }

  /// Watch all recommendations (real-time)
  Stream<List<Recommendation>> watchAllRecommendations() {
    return FirestoreCollections.recommendationsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Recommendation.fromFirestore(doc)).toList());
  }

  /// Get recommendation by crop and objective
  Future<Recommendation?> getRecommendationByCropAndObjective(
    String cropId,
    String objectiveId,
  ) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.recommendationsRef
          .doc('${cropId}_${objectiveId}')
          .get();

      return doc.exists ? Recommendation.fromFirestore(doc) : null;
    });
  }

  /// Watch recommendation by crop and objective (real-time)
  Stream<Recommendation?> watchRecommendationByCropAndObjective(
    String cropId,
    String objectiveId,
  ) {
    return FirestoreCollections.recommendationsRef
        .doc('${cropId}_${objectiveId}')
        .snapshots()
        .map((doc) => doc.exists ? Recommendation.fromFirestore(doc) : null);
  }

  /// Get recommendations for a specific crop
  Future<List<Recommendation>> getRecommendationsForCrop(String cropId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot =
          await FirestoreQueries.recommendationsForCrop(cropId).get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }

  /// Create recommendation
  Future<void> createRecommendation(Recommendation recommendation) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.recommendationsRef
          .doc(recommendation.documentId)
          .set({
        ...recommendation.toFirestore(),
        'cropId': recommendation.cropId,
        'objectiveId': recommendation.objectiveId,
        'createdAt': Timestamp.now(),
      });
    });
  }

  /// Update recommendation
  Future<void> updateRecommendation(
    String cropId,
    String objectiveId,
    Map<String, dynamic> updates,
  ) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.recommendationsRef
          .doc('${cropId}_${objectiveId}')
          .update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete recommendation
  Future<void> deleteRecommendation(String cropId, String objectiveId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.recommendationsRef
          .doc('${cropId}_${objectiveId}')
          .delete();
    });
  }

  /// Get recommendations containing specific product
  Future<List<Recommendation>> getRecommendationsWithProduct(
      String productId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.recommendationsRef
          .where('items', arrayContainsAny: [
        {'productId': productId}
      ]).get();

      return snapshot.docs
          .map((doc) => Recommendation.fromFirestore(doc))
          .toList();
    });
  }
}
