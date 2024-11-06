import 'dart:convert';

class UserDetails {
  final String name;
  final String address;

  UserDetails({required this.name, required this.address});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
    };
  }
}