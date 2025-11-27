import 'package:cloud_firestore/cloud_firestore.dart';

import '../api/collections.dart';
import '../api/firestore_client.dart';
import '../models/product.dart';

class ProductCatalogRepository {
  final FirestoreClient _client;

  ProductCatalogRepository(this._client);

  /// Get all products in catalog
  Future<List<Product>> getAllCatalogProducts() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productCatalogRef.get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  /// Watch all catalog products (real-time)
  Stream<List<Product>> watchAllCatalogProducts() {
    return FirestoreCollections.productCatalogRef.snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Get product by ID
  Future<Product?> getCatalogProductById(String productId) async {
    return await FirestoreClient.executeOperation(() async {
      final doc = await FirestoreCollections.productCatalogDoc(productId).get();
      return doc.exists ? Product.fromFirestore(doc) : null;
    });
  }

  /// Watch product by ID (real-time)
  Stream<Product?> watchCatalogProductById(String productId) {
    return FirestoreCollections.productCatalogDoc(productId)
        .snapshots()
        .map((doc) => doc.exists ? Product.fromFirestore(doc) : null);
  }

  /// Create new product in catalog
  Future<void> createCatalogProduct(Product product) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productCatalogDoc(product.id).set({
        ...product.toFirestore(),
        'createdAt': Timestamp.now(),
      });
    });
  }

  /// Update product in catalog
  Future<void> updateCatalogProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productCatalogDoc(productId).update({
        ...updates,
        'updatedAt': Timestamp.now(),
      });
    });
  }

  /// Delete product from catalog
  Future<void> deleteCatalogProduct(String productId) async {
    await FirestoreClient.executeOperation(() async {
      await FirestoreCollections.productCatalogDoc(productId).delete();
    });
  }

  /// Get products by category
  Future<List<Product>> getProductsByCategory(String category) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productCatalogRef
          .where('category', isEqualTo: category)
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  /// Watch products by category (real-time)
  Stream<List<Product>> watchProductsByCategory(String category) {
    return FirestoreCollections.productCatalogRef
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Search products by name
  Future<List<Product>> searchProducts(String query) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productCatalogRef
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: query + '\uf8ff')
          .orderBy('name')
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  /// Get featured/bestseller products
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productCatalogRef
          .where('isFeatured', isEqualTo: true)
          .limit(limit)
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  /// Watch featured products (real-time)
  Stream<List<Product>> watchFeaturedProducts({int limit = 10}) {
    return FirestoreCollections.productCatalogRef
        .where('isFeatured', isEqualTo: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList());
  }

  /// Get products by price range
  Future<List<Product>> getProductsByPriceRange(
    double minPrice,
    double maxPrice,
  ) async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productCatalogRef
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice)
          .orderBy('price')
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  /// Get products with deals
  Future<List<Product>> getProductsWithDeals() async {
    return await FirestoreClient.executeOperation(() async {
      final snapshot = await FirestoreCollections.productCatalogRef
          .where('dealId', isNull: false)
          .get();

      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }
}
