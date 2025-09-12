import 'alternative.dart'; // Import the corrected Alternative model

class Product {
  final String id;
  final String title;
  final List<String> imageUrls;
  final double mrp;
  final String broadCategory;
  final List<String> crops;
  final double? savings;
  final String? openUrl;
  final String? activeIngredient;
  final String? chemicalComposition;
  final String? modeOfAction;
  final String? usageDirection;
  final List<Alternative>? alternatives;

  // Added const constructor for immutability
  const Product({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.mrp,
    required this.broadCategory,
    required this.crops,
    this.savings,
    this.openUrl,
    this.activeIngredient,
    this.chemicalComposition,
    this.modeOfAction,
    this.usageDirection,
    this.alternatives,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse alternatives with additional type checking
    List<Alternative>? parsedAlternatives;
    if (json['alternatives'] is List) {
      try {
        parsedAlternatives = (json['alternatives'] as List)
            .where((altJson) => altJson is Map<String, dynamic>) // Ensure each item is a valid map
            .map((altJson) => Alternative.fromJson(altJson as Map<String, dynamic>))
            .toList();
      } catch (e) {
        // Log error for debugging (replace with your preferred logging mechanism)
        print('Error parsing alternatives: $e');
      }
    }

    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'No Title',
      imageUrls: json['image_urls'] is List
          ? (json['image_urls'] as List)
              .where((e) => e != null) // Filter out null values
              .map((e) => e.toString())
              .toList()
          : [],
      mrp: _parseDouble(json['mrp']),
      broadCategory: json['broad_category']?.toString() ?? 'N/A',
      crops: json['crops'] is List
          ? (json['crops'] as List)
              .where((e) => e != null)
              .map((e) => e.toString())
              .toList()
          : [],
      savings: _parseDoubleOptional(json['savings']),
      openUrl: json['open_url']?.toString(),
      activeIngredient: json['active_ingredient']?.toString(),
      chemicalComposition: json['chemical_composition']?.toString(),
      modeOfAction: json['mode_of_action']?.toString(),
      usageDirection: json['usage_direction']?.toString(),
      alternatives: parsedAlternatives,
    );
  }



  // Helper method to safely convert to double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        print('Invalid double value: $value'); // Log for debugging
        return 0.0;
      }
      return parsed;
    }
    print('Unsupported double type: $value'); // Log for debugging
    return 0.0;
  }

  // Helper method to safely convert to nullable double
  static double? _parseDoubleOptional(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed == null) {
        print('Invalid optional double value: $value'); // Log for debugging
      }
      return parsed;
    }
    print('Unsupported optional double type: $value'); // Log for debugging
    return null;
  }
}
