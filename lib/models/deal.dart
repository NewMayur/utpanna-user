class Deal {
  final int id;
  final String title;
  final String description;
  final double price;
  final int min_participants;
  final int current_participants;
  final String status;

  Deal({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.min_participants,
    required this.current_participants,
    required this.status,
  });

  factory Deal.fromJson(Map<String, dynamic> json) {
    return Deal(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      min_participants: json['min_participants'],
      current_participants: json['current_participants'],
      status: json['status'],
    );
  }
}