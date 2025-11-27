import 'package:cloud_firestore/cloud_firestore.dart';

import 'firestore_client.dart';

/// Firebase Firestore collection references
class FirestoreCollections {
  // Collection constants
  static const String crops = 'crops';
  static const String objectives = 'objectives';
  static const String products =
      'products'; // Farming products - JSON loaded, to be migrated
  static const String recommendations = 'recommendations';
  static const String deals = 'deals'; // Deal commerce system
  static const String users = 'users'; // User profiles
  static const String productCatalog =
      'product_catalog'; // API products (different from farming products)
  static const String alternatives = 'alternatives'; // Product alternatives

  // Collection references
  static CollectionReference<Map<String, dynamic>> get cropsRef =>
      FirestoreClient.firestore.collection(crops);

  static CollectionReference<Map<String, dynamic>> get objectivesRef =>
      FirestoreClient.firestore.collection(objectives);

  static CollectionReference<Map<String, dynamic>> get productsRef =>
      FirestoreClient.firestore.collection(products);

  static CollectionReference<Map<String, dynamic>> get recommendationsRef =>
      FirestoreClient.firestore.collection(recommendations);

  static CollectionReference<Map<String, dynamic>> get dealsRef =>
      FirestoreClient.firestore.collection(deals);

  static CollectionReference<Map<String, dynamic>> get usersRef =>
      FirestoreClient.firestore.collection(users);

  static CollectionReference<Map<String, dynamic>> get productCatalogRef =>
      FirestoreClient.firestore.collection(productCatalog);

  static CollectionReference<Map<String, dynamic>> get alternativesRef =>
      FirestoreClient.firestore.collection(alternatives);

  /// Document references
  static DocumentReference<Map<String, dynamic>> cropDoc(String cropId) =>
      cropsRef.doc(cropId);

  static DocumentReference<Map<String, dynamic>> objectiveDoc(
          String objectiveId) =>
      objectivesRef.doc(objectiveId);

  static DocumentReference<Map<String, dynamic>> productDoc(String productId) =>
      productsRef.doc(productId);

  static DocumentReference<Map<String, dynamic>> recommendationDoc(
          String recommendationId) =>
      recommendationsRef.doc(recommendationId);

  static DocumentReference<Map<String, dynamic>> dealDoc(String dealId) =>
      dealsRef.doc(dealId);

  static DocumentReference<Map<String, dynamic>> userDoc(String userId) =>
      usersRef.doc(userId);

  static DocumentReference<Map<String, dynamic>> productCatalogDoc(
          String productId) =>
      productCatalogRef.doc(productId);

  static DocumentReference<Map<String, dynamic>> alternativeDoc(
          String alternativeId) =>
      alternativesRef.doc(alternativeId);
}

/// Firestore collection groups for queries
class FirestoreQueries {
  /// Query active deals
  static Query<Map<String, dynamic>> get activeDeals =>
      FirestoreCollections.dealsRef.where('isActive', isEqualTo: true);

  /// Query products by category
  static Query<Map<String, dynamic>> productsByCategory(String category) =>
      FirestoreCollections.productsRef.where('category', isEqualTo: category);

  /// Query recommendations for a specific crop
  static Query<Map<String, dynamic>> recommendationsForCrop(String cropId) =>
      FirestoreCollections.recommendationsRef
          .where('cropId', isEqualTo: cropId);

  /// Query recommendations by crop and objective
  static Query<Map<String, dynamic>> recommendationsByCropAndObjective(
    String cropId,
    String objectiveId,
  ) =>
      FirestoreCollections.recommendationsRef
          .where('cropId', isEqualTo: cropId)
          .where('objectiveId', isEqualTo: objectiveId);

  /// Query user deals participation
  static Query<Map<String, dynamic>> userParticipatedDeals(String userId) =>
      FirestoreCollections.dealsRef
          .where('participants', arrayContains: userId);
}
