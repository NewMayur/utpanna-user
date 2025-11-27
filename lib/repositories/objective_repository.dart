import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/farming_models.dart';

class ObjectiveRepository {
  final FirestoreClient _client;

  ObjectiveRepository(this._client);

  /// Get all objectives
  Future<List<Objective>> getAllObjectives() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot =
          await FirestoreCollections.objectivesRef.orderBy('name').get();

      return snapshot.docs.map((doc) => Objective.fromFirestore(doc)).toList();
    });
  }

  /// Watch all objectives (real-time)
  Stream<List<Objective>> watchAllObjectives() {
    return FirestoreCollections.objectivesRef.orderBy('name').snapshots().map(
        (snapshot) =>
            snapshot.docs.map((doc) => Objective.fromFirestore(doc)).toList());
  }

  /// Get objective by ID
  Future<Objective?> getObjectiveById(String objectiveId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.objectiveDoc(objectiveId).get();
      return doc.exists ? Objective.fromFirestore(doc) : null;
    });
  }

  /// Watch objective by ID (real-time)
  Stream<Objective?> watchObjectiveById(String objectiveId) {
    return FirestoreCollections.objectiveDoc(objectiveId)
        .snapshots()
        .map((doc) => doc.exists ? Objective.fromFirestore(doc) : null);
  }

  /// Create new objective
  Future<void> createObjective(Objective objective) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.objectiveDoc(objective.id).set({
        ...objective.toFirestore(),
        'createdAt': Timestamp.now(),
      });
    });
  }

  /// Update objective
  Future<void> updateObjective(
      String objectiveId, Map<String, dynamic> updates) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.objectiveDoc(objectiveId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete objective
  Future<void> deleteObjective(String objectiveId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.objectiveDoc(objectiveId).delete();
    });
  }

  /// Search objectives by name
  Future<List<Objective>> searchObjectives(String query) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.objectivesRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => Objective.fromFirestore(doc)).toList();
    });
  }
}
