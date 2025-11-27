import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/farming_models.dart';

class ProductRepository {
  final FirestoreClient _client;

  ProductRepository(this._client);

  /// Get all products
  Future<List<FarmingProduct>> getAllProducts() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot =
          await FirestoreCollections.productsRef.orderBy('name').get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Watch all products (real-time)
  Stream<List<FarmingProduct>> watchAllProducts() {
    return FirestoreCollections.productsRef.orderBy('name').snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => FarmingProduct.fromFirestore(doc))
            .toList());
  }

  /// Get product by ID
  Future<FarmingProduct?> getProductById(String productId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.productDoc(productId).get();
      return doc.exists ? FarmingProduct.fromFirestore(doc) : null;
    });
  }

  /// Watch product by ID (real-time)
  Stream<FarmingProduct?> watchProductById(String productId) {
    return FirestoreCollections.productDoc(productId)
        .snapshots()
        .map((doc) => doc.exists ? FarmingProduct.fromFirestore(doc) : null);
  }

  /// Create new product
  Future<void> createProduct(FarmingProduct product) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productDoc(product.id).set({
        ...product.toFirestore(),
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Update product
  Future<void> updateProduct(
      String productId, Map<String, dynamic> updates) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productDoc(productId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete product
  Future<void> deleteProduct(String productId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productDoc(productId).delete();
    });
  }

  /// Get products by category
  Future<List<FarmingProduct>> getProductsByCategory(String category) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot =
          await FirestoreQueries.productsByCategory(category).get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Watch products by category (real-time)
  Stream<List<FarmingProduct>> watchProductsByCategory(String category) {
    return FirestoreQueries.productsByCategory(category).snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => FarmingProduct.fromFirestore(doc))
            .toList());
  }

  /// Search products by name
  Future<List<FarmingProduct>> searchProducts(String query) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }

  /// Get products with active deals
  Future<List<FarmingProduct>> getProductsWithActiveDeals() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productsRef
          .where('activeDealUuid', isNull: false)
          .get();

      return snapshot.docs
          .map((doc) => FarmingProduct.fromFirestore(doc))
          .toList();
    });
  }
}
