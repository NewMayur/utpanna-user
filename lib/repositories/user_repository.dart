import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/user_details.dart';

class UserRepository {
  final FirestoreClient _client;

  UserRepository(this._client);

  /// Get user by ID
  Future<UserDetails?> getUserById(String userId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.userDoc(userId).get();
      return doc.exists ? UserDetails.fromFirestore(doc) : null;
    });
  }

  /// Watch user by ID (real-time)
  Stream<UserDetails?> watchUserById(String userId) {
    return FirestoreCollections.userDoc(userId)
        .snapshots()
        .map((doc) => doc.exists ? UserDetails.fromFirestore(doc) : null);
  }

  /// Create new user
  Future<void> createUser(UserDetails user) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.userDoc(user.id).set({
        ...user.toFirestore(),
        'createdAt': Timestamp.now(),
      });
    });
  }

  /// Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.userDoc(userId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete user
  Future<void> deleteUser(String userId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.userDoc(userId).delete();
    });
  }

  /// Get user by phone number (login)
  Future<UserDetails?> getUserByPhone(String phoneNumber) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return UserDetails.fromFirestore(snapshot.docs.first);
    });
  }

  /// Check if phone number exists (registration)
  Future<bool> phoneNumberExists(String phoneNumber) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    });
  }

  /// Update user login timestamp
  Future<void> updateLastLogin(String userId) async {
    await updateUser(userId, {
      'lastLoginAt': Timestamp.now(),
    });
  }

  /// Get users registered after a certain date (analytics)
  Future<List<UserDetails>> getUsersRegisteredAfter(Timestamp date) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('createdAt', isGreaterThan: date)
          .orderBy('createdAt')
          .get();

      return snapshot.docs
          .map((doc) => UserDetails.fromFirestore(doc))
          .toList();
    });
  }

  /// Get total user count (admin/stats)
  Future<int> getUserCount() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef.get();
      return snapshot.docs.length;
    });
  }

  /// Search users by name
  Future<List<UserDetails>> searchUsersByName(String query) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => UserDetails.fromFirestore(doc))
          .toList();
    });
  }

  /// Add participated deal to user
  Future<void> addParticipatedDeal(String userId, String dealId) async {
    await FirestoreClient.executeOperation(() async {
      final userDoc = FirestoreCollections.userDoc(userId);

      // Use FieldValue.arrayUnion to atomically add to the array
      await userDoc.update({
        'participatedDeals': FieldValue.arrayUnion([dealId]),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Remove participated deal from user (for cancellations/refunds)
  Future<void> removeParticipatedDeal(String userId, String dealId) async {
    await FirestoreClient.executeOperation(() async {
      final userDoc = FirestoreCollections.userDoc(userId);

      // Use FieldValue.arrayRemove to atomically remove from the array
      await userDoc.update({
        'participatedDeals': FieldValue.arrayRemove([dealId]),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Check if user has participated in a deal
  Future<bool> hasParticipatedInDeal(String userId, String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      final userDoc = FirestoreCollections.userDoc(userId).get();
      final snapshot = await userDoc;
      if (!snapshot.exists) return false;

      final user = UserDetails.fromFirestore(snapshot);
      return user.participatedDeals.contains(dealId);
    });
  }

  /// Get user's participated deals
  Future<List<String>> getUserParticipatedDeals(String userId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.userDoc(userId).get();
      if (!doc.exists) return [];

      final user = UserDetails.fromFirestore(doc);
      return user.participatedDeals;
    });
  }

  /// Get users who participated in a specific deal (admin/analytics)
  Future<List<UserDetails>> getUsersParticipatedInDeal(String dealId) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.usersRef
          .where('participatedDeals', arrayContains: dealId)
          .get();

      return snapshot.docs
          .map((doc) => UserDetails.fromFirestore(doc))
          .toList();
    });
  }
}
