class Alternative {
  final int id;
  final int productId;
  final String title;
  final String imageUrl;
  final int price;
  final int savings;
  final String chemicalComposition;
  final String modeOfAction;
  final String activeIngredient;
  final String usageDirection;
  final List<String> usedFor;

  Alternative({
    required this.id,
    required this.productId,
    required this.title,
    required this.imageUrl,
    required this.price,
    required this.savings,
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
      imageUrl: (json['image_url'] ?? '').toString(),
      price: _parseToInt(json['price']),
      savings: _parseToInt(json['savings']),
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
}
