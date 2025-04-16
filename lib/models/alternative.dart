class Alternative {
  final int id;
  final int productId;
  final String title;
  final List<String> imageUrls; // Changed from String to List<String>
  final double price; // Changed to double
  final double savings; // Changed to double
  final String chemicalComposition;
  final String modeOfAction;
  final String activeIngredient;
  final String usageDirection;
  final List<String> usedFor;

  Alternative({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrls, // Updated field name
    required this.price, // Changed to double
    required this.savings, // Changed to double
    required this.chemicalComposition,
    required this.modeOfAction,
    required this.activeIngredient,
    required this.usageDirection,
    required this.usedFor,
  });

  factory Alternative.fromJson(Map<String, dynamic> json) {
    return Alternative(
      id: _parseToInt(json['id']),
      productId: _parseToInt(json['product_id']),
      title: (json['title'] ?? '').toString(),
      // Parse image_urls list
      imageUrls: json['image_urls'] is List
          ? List<String>.from(json['image_urls'].map((e) => e.toString()))
          : [], // Default to empty list if not a list
      price: _parseDouble(json['price']), // Use _parseDouble
      savings: _parseDouble(json['savings']), // Use _parseDouble
      chemicalComposition: (json['chemical_composition'] ?? '').toString(),
      modeOfAction: (json['mode_of_action'] ?? '').toString(),
      activeIngredient: (json['active_ingredient'] ?? '').toString(),
      usageDirection: (json['usage_direction'] ?? '').toString(),
      usedFor: json['used_for'] is List 
        ? List<String>.from(json['used_for'].map((e) => e.toString())) 
        : [],
    );
  }

  // Helper method to safely convert to int
  static int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // Helper method to safely convert to double (copied from product.dart)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
