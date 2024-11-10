class Deal {
  final int id;
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
      id: json['id'],
      title: json['title'],
      description: json['description'],
      mrp: json['mrp']?.toDouble() ?? 0.0,
      deal_price: json['deal_price']?.toDouble() ?? 0.0,
      min_participants: json['min_participants'],
      current_participants: json['current_participants'],
      status: json['status'],
      progress_percentage: json['progress_percentage']?.toDouble() ?? 0.0,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
    );
  }

  int get spotsAvailable => min_participants - current_participants;
}
