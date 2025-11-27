import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/alternative.dart';

class AlternativeRepository {
  final FirestoreClient _client;

  AlternativeRepository(this._client);

  /// Get all alternatives
  Future<List<Alternative>> getAllAlternatives() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.alternativesRef.get();

      return snapshot.docs
          .map((doc) => Alternative.fromFirestore(doc))
          .toList();
    });
  }

  /// Watch all alternatives (real-time)
  Stream<List<Alternative>> watchAllAlternatives() {
    return FirestoreCollections.alternativesRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Alternative.fromFirestore(doc)).toList());
  }

  /// Get alternative by ID
  Future<Alternative?> getAlternativeById(String alternativeId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc =
          await FirestoreCollections.alternativeDoc(alternativeId).get();
      return doc.exists ? Alternative.fromFirestore(doc) : null;
    });
  }

  /// Watch alternative by ID (real-time)
  Stream<Alternative?> watchAlternativeById(String alternativeId) {
    return FirestoreCollections.alternativeDoc(alternativeId)
        .snapshots()
        .map((doc) => doc.exists ? Alternative.fromFirestore(doc) : null);
  }

  /// Get alternatives for a specific product
  Future<List<Alternative>> getAlternativesForProduct(String productId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.alternativesRef
          .where('productId', isEqualTo: productId)
          .get();

      return snapshot.docs
          .map((doc) => Alternative.fromFirestore(doc))
          .toList();
    });
  }

  /// Watch alternatives for a specific product (real-time)
  Stream<List<Alternative>> watchAlternativesForProduct(String productId) {
    return FirestoreCollections.alternativesRef
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alternative.fromFirestore(doc))
            .toList());
  }

  /// Create new alternative
  Future<void> createAlternative(Alternative alternative) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.alternativeDoc(alternative.id).set({
        ...alternative.toFirestore(),
        'createdAt': Timestamp.now(),
      });
    });
  }

  /// Update alternative
  Future<void> updateAlternative(
    String alternativeId,
    Map<String, dynamic> updates,
  ) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.alternativeDoc(alternativeId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete alternative
  Future<void> deleteAlternative(String alternativeId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.alternativeDoc(alternativeId).delete();
    });
  }

  /// Increment view count for an alternative (atomic operation)
  Future<void> incrementViewCount(String alternativeId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreClient.executeTransaction((transaction) async {
        final alternativeRef =
            FirestoreCollections.alternativeDoc(alternativeId);
        final alternativeDoc = await transaction.get(alternativeRef);

        if (!alternativeDoc.exists) {
          throw Exception('Alternative not found');
        }

        final currentViews = alternativeDoc.data()?['viewCount'] ?? 0;
        final updatedViews = currentViews + 1;

        transaction.update(alternativeRef, {
          'viewCount': updatedViews,
          'updatedAt': Timestamp.now(),
        });
      });
    });
  }

  /// Get most viewed alternatives (ordered by view count)
  Future<List<Alternative>> getMostViewedAlternatives({int limit = 10}) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.alternativesRef
          .orderBy('viewCount', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => Alternative.fromFirestore(doc))
          .toList();
    });
  }

  /// Watch alternatives by popularity (most viewed)
  Stream<List<Alternative>> watchMostViewedAlternatives({int limit = 10}) {
    return FirestoreCollections.alternativesRef
        .orderBy('viewCount', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Alternative.fromFirestore(doc))
            .toList());
  }
}
