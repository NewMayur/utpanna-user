import 'package:cloud_firestore/cloud_firestore.dart';

class Crop {
  final String id;
  final String name;
  final String imageAsset;

  Crop({
    required this.id,
    required this.name,
    required this.imageAsset,
  });

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageAsset: json['image_asset'] ?? '',
    );
  }

  factory Crop.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Crop(
      id: doc.id,
      name: data['name'] ?? '',
      imageAsset: data['imageAsset'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'imageAsset': imageAsset,
    };
  }
}

class Objective {
  final String id;
  final String name;

  Objective({
    required this.id,
    required this.name,
  });

  factory Objective.fromJson(Map<String, dynamic> json) {
    return Objective(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  factory Objective.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Objective(
      id: doc.id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}

class FarmingProduct {
  final String id;
  final String name;
  final String category;
  final double price;
  final double mrp;
  final String unit;
  final String? imageUrl;
  final String? activeDealUuid;

  FarmingProduct({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.mrp,
    required this.unit,
    this.imageUrl,
    this.activeDealUuid,
  });

  factory FarmingProduct.fromJson(Map<String, dynamic> json) {
    return FarmingProduct(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      mrp: (json['mrp'] ?? json['price'] ?? 0)
          .toDouble(), // Use price as MRP if MRP not available
      unit: json['unit'] ?? '',
      imageUrl: json['image_url'],
      activeDealUuid: json['active_deal_uuid'],
    );
  }

  factory FarmingProduct.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FarmingProduct(
      id: doc.id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      mrp: (data['mrp'] ?? data['price'] ?? 0).toDouble(),
      unit: data['unit'] ?? '',
      imageUrl: data['imageUrl'],
      activeDealUuid: data['activeDealUuid'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'mrp': mrp,
      'unit': unit,
      'imageUrl': imageUrl,
      'activeDealUuid': activeDealUuid,
    };
  }

  // Calculate discount percentage
  double get discountPercent {
    if (mrp <= 0) return 0;
    return ((mrp - price) / mrp * 100).roundToDouble();
  }
}

class RecommendationItem {
  final String productId;
  final double qtyAcre;
  final double qtyPump;

  RecommendationItem({
    required this.productId,
    required this.qtyAcre,
    required this.qtyPump,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      productId: json['product_id'] ?? '',
      qtyAcre: (json['qty_acre'] ?? 0).toDouble(),
      qtyPump: (json['qty_pump'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'qty_acre': qtyAcre,
      'qty_pump': qtyPump,
    };
  }

  factory RecommendationItem.fromFirestore(Map<String, dynamic> data) {
    return RecommendationItem(
      productId: data['productId'] ?? '',
      qtyAcre: (data['qtyAcre'] ?? 0).toDouble(),
      qtyPump: (data['qtyPump'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'productId': productId,
      'qtyAcre': qtyAcre,
      'qtyPump': qtyPump,
    };
  }
}

class Recommendation {
  final String cropId;
  final String objectiveId;
  final String dealUuid;
  final String comboTitle;
  final List<RecommendationItem> items;

  Recommendation({
    required this.cropId,
    required this.objectiveId,
    required this.dealUuid,
    required this.comboTitle,
    required this.items,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      cropId: json['crop_id'] ?? '',
      objectiveId: json['objective_id'] ?? '',
      dealUuid: json['deal_uuid'] ?? '',
      comboTitle: json['combo_title'] ?? '',
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => RecommendationItem.fromJson(item))
          .toList(),
    );
  }

  factory Recommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Recommendation(
      cropId: doc.id.split('_')[0], // Assuming ID format: cropId_objectiveId
      objectiveId: doc.id.split('_')[1],
      dealUuid: data['dealUuid'] ?? '',
      comboTitle: data['comboTitle'] ?? '',
      items: (data['items'] as List<dynamic>? ?? [])
          .map((item) => RecommendationItem.fromFirestore(item))
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'dealUuid': dealUuid,
      'comboTitle': comboTitle,
      'items': items.map((item) => item.toFirestore()).toList(),
    };
  }

  String get documentId => '${cropId}_${objectiveId}';
}

class FarmingData {
  final List<Crop> crops;
  final List<Objective> objectives;
  final List<FarmingProduct> products;
  final List<Recommendation> recommendations;

  FarmingData({
    required this.crops,
    required this.objectives,
    required this.products,
    required this.recommendations,
  });

  factory FarmingData.fromJson(Map<String, dynamic> json) {
    return FarmingData(
      crops: (json['crops'] as List<dynamic>? ?? [])
          .map((crop) => Crop.fromJson(crop))
          .toList(),
      objectives: (json['objectives'] as List<dynamic>? ?? [])
          .map((objective) => Objective.fromJson(objective))
          .toList(),
      products: (json['products'] as List<dynamic>? ?? [])
          .map((product) => FarmingProduct.fromJson(product))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>? ?? [])
          .map((recommendation) => Recommendation.fromJson(recommendation))
          .toList(),
    );
  }
}
