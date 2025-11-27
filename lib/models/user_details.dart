import 'package:cloud_firestore/cloud_firestore.dart';

class UserDetails {
  final String id; // Firebase Auth UID
  final String name;
  final String phoneNumber;
  final String address;
  final List<String> participatedDeals;

  UserDetails({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.address = '',
    this.participatedDeals = const [],
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) {
    return UserDetails(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phoneNumber']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      participatedDeals: List<String>.from(json['participatedDeals'] ?? []),
    );
  }

  factory UserDetails.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserDetails(
      id: doc.id,
      name: data['name'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      participatedDeals: List<String>.from(data['participatedDeals'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'participatedDeals': participatedDeals,
    };
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'address': address,
      'participatedDeals': participatedDeals,
    };
  }

  // Enhanced copyWith with participatedDeals support
  UserDetails copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? address,
    List<String>? participatedDeals,
  }) {
    return UserDetails(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      participatedDeals: participatedDeals ?? this.participatedDeals,
    );
  }
}
