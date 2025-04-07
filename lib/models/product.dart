import 'alternative.dart'; // Import the corrected Alternative model

class Product {
  final int id;
  final String title;
  final String imageUrl;
  final double mrp; // Changed to double based on API response example (100.5)
  final String broadCategory;
  final List<String> crops;
  final double? savings; // Changed to double? based on API response example (10.5)
  final String? openUrl; // Made nullable as it might not always be present
  final String? activeIngredient;
  final String? chemicalComposition;
  final String? modeOfAction;
  final String? usageDirection;
  final List<Alternative>? alternatives; // Changed to use Alternative model

  Product({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.mrp,
    required this.broadCategory,
    required this.crops,
    this.savings,
    this.openUrl,
    this.activeIngredient,
    this.chemicalComposition,
    this.modeOfAction,
    this.usageDirection,
    this.alternatives, // Changed to use Alternative model
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse alternatives using the imported Alternative model
    List<Alternative>? parsedAlternatives;
    if (json['alternatives'] is List) {
      parsedAlternatives = (json['alternatives'] as List)
          .map((altJson) => Alternative.fromJson(altJson)) // Use Alternative.fromJson
          .toList();
    }

    return Product(
      id: _parseToInt(json['id']),
      title: json['title']?.toString() ?? 'No Title',
      imageUrl: json['image_url']?.toString() ?? '',
      mrp: _parseDouble(json['mrp']),
      broadCategory: json['broad_category']?.toString() ?? 'N/A',
      crops: json['crops'] is List
          ? List<String>.from(json['crops'].map((e) => e.toString()))
          : [],
      savings: _parseDoubleOptional(json['savings']),
      openUrl: json['open_url']?.toString(), // Keep as nullable string
      activeIngredient: json['active_ingredient']?.toString(),
      chemicalComposition: json['chemical_composition']?.toString(),
      modeOfAction: json['mode_of_action']?.toString(),
      usageDirection: json['usage_direction']?.toString(),
      alternatives: parsedAlternatives,
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

  // Helper method to safely convert to double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

   // Helper method to safely convert to nullable double
  static double? _parseDoubleOptional(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }
}

// Removed the redundant AlternativeProduct class
