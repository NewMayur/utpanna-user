class Deal {
  final String id;
  final String title;
  final String description;
  final double mrp;
  final double deal_price;
  final int min_participants;
  final int current_participants;
  final String status;
  final double progress_percentage;
  final List<String>? images;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.mrp,
    required this.deal_price,
    required this.min_participants,
    required this.current_participants,
    required this.status,
    required this.progress_percentage,
    this.images,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mrp: _parseDouble(json['mrp']),
      deal_price: _parseDouble(json['deal_price']),
      min_participants: _parseInt(json['min_participants']),
      current_participants: _parseInt(json['current_participants']),
      status: json['status']?.toString() ?? '',
      progress_percentage: _parseDouble(json['progress_percentage']),
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  // Helper method to safely convert to double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  // Helper method to safely convert to int
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  int get spotsAvailable => min_participants - current_participants;
}
