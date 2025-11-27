import 'package:cloud_firestore/cloud_firestore.dart';

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
  final List<String> participants; // List of user IDs who joined the deal

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
    this.participants = const [],
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
      participants: json['participants'] != null
          ? List<String>.from(json['participants'])
          : [],
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

  factory Deal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Deal(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      mrp: _parseDouble(data['mrp']),
      deal_price: _parseDouble(data['dealPrice']),
      min_participants: _parseInt(data['minParticipants']),
      current_participants: _parseInt(data['currentParticipants']),
      status: data['status'] ?? '',
      progress_percentage: _parseDouble(data['progressPercentage']),
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      participants: data['participants'] != null
          ? List<String>.from(data['participants'])
          : [],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'mrp': mrp,
      'dealPrice': deal_price,
      'minParticipants': min_participants,
      'currentParticipants': current_participants,
      'status': status,
      'progressPercentage': progress_percentage,
      'images': images,
      'participants': participants,
    };
  }

  int get spotsAvailable => min_participants - current_participants;
}
