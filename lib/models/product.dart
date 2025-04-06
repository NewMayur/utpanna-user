class Product {
  final int id;
  final String title;
  final String imageUrl;
  final int mrp;
  final String broadCategory;
  final List<String> crops;
  final int savings;
  final String openUrl;

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.mrp,
    required this.broadCategory,
    required this.crops,
    required this.savings,
    required this.openUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseToInt(json['id']),
      title: json['title'].toString(),
      imageUrl: json['image_url'].toString(),
      mrp: _parseToInt(json['mrp']),
      broadCategory: json['broad_category'].toString(),
      crops: json['crops'] is List 
        ? List<String>.from(json['crops'].map((e) => e.toString())) 
        : [],
      savings: _parseToInt(json['savings']),
      openUrl: json['open_url'].toString(),
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
