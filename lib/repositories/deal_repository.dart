import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/deal.dart';

class DealRepository {
  final FirestoreClient _client;

  DealRepository(this._client);

  /// Get all deals
  Future<List<Deal>> getAllDeals() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.dealsRef.get();

      return snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList();
    });
  }

  /// Watch all deals (real-time)
  Stream<List<Deal>> watchAllDeals() {
    return FirestoreCollections.dealsRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList());
  }

  /// Get deal by ID
  Future<Deal?> getDealById(String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.dealDoc(dealId).get();
      return doc.exists ? Deal.fromFirestore(doc) : null;
    });
  }

  /// Watch deal by ID (real-time)
  Stream<Deal?> watchDealById(String dealId) {
    return FirestoreCollections.dealDoc(dealId)
        .snapshots()
        .map((doc) => doc.exists ? Deal.fromFirestore(doc) : null);
  }

  /// Create new deal
  Future<void> createDeal(Deal deal) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.dealDoc(deal.id).set({
        ...deal.toFirestore(),
        'createdAt': Timestamp.now(),
      });
    });
  }

  /// Update deal
  Future<void> updateDeal(String dealId, Map<String, dynamic> updates) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.dealDoc(dealId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete deal
  Future<void> deleteDeal(String dealId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.dealDoc(dealId).delete();
    });
  }

  /// Get active deals (not yet at minimum participants)
  Future<List<Deal>> getActiveDeals() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreQueries.activeDeals.get();

      return snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList();
    });
  }

  /// Watch active deals (real-time)
  Stream<List<Deal>> watchActiveDeals() {
    return FirestoreQueries.activeDeals.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList());
  }

  /// Participate in a deal
  Future<void> participateInDeal(String dealId, String userId) async {
    await FirestoreClient.executeOperation(() async {
      // Use Firestore transaction to ensure atomic update
      await FirestoreClient.executeTransaction((transaction) async {
        final dealRef = FirestoreCollections.dealDoc(dealId);
        final dealDoc = await transaction.get(dealRef);

        if (!dealDoc.exists) {
          throw Exception('Deal not found');
        }

        final deal = Deal.fromFirestore(dealDoc);
        final updatedParticipantsCount = deal.current_participants + 1;

        // Create updated participants list with new user ID
        final updatedParticipantsList = [...deal.participants, userId];

        transaction.update(dealRef, {
          'currentParticipants': updatedParticipantsCount,
          'participants': updatedParticipantsList,
          'updatedAt': Timestamp.now(),
        });
      });
    });
  }

  /// Get deals participated by user
  Future<List<Deal>> getUserParticipatedDeals(String userId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot =
          await FirestoreQueries.userParticipatedDeals(userId).get();

      return snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList();
    });
  }

  /// Watch deals user has participated in
  Stream<List<Deal>> watchUserParticipatedDeals(String userId) {
    return FirestoreQueries.userParticipatedDeals(userId).snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Deal.fromFirestore(doc)).toList());
  }
}
