import 'package:flutter/widgets.dart';

class UserModel {
  final String id;
  final String? address;
  final bool? agreeTermsAndConditions;
  final List<String>? appointments;
  final String? email;
  final String? name;
  final String? phoneNumber;
  final String? photoURL;
  final String? stripeId;
  final String? surname;

  UserModel(this.id, this.address, this.agreeTermsAndConditions, this.appointments, this.email, this.name, this.phoneNumber, this.photoURL,
      this.stripeId, this.surname);

  String getFullName() {
    return '${(name?.capitalizeFirstLetter() ?? "")} ${(surname?.capitalizeFirstLetter() ?? "")}';
  }

  ImageProvider profilePicture() {
    if (photoURL == null || photoURL!.isEmpty) {
      return const AssetImage('assets/images/default-user.png');
    } else {
      return NetworkImage(photoURL!);
    }
  }

  factory UserModel.fromJson(String id, Map<String, dynamic> json) {
    return UserModel(
      id,
      json['address'] as String?,
      json['agreeTermsAndConditions'] as bool?,
      List<String>.from(json['appointments'] != null ? json['appointments'] as List : List.empty()),
      json['email'] as String?,
      json['name'] as String?,
      json['phonenumber'] as String?,
      json['photoURL'] as String?,
      json['stripe_id'] as String?,
      json['surname'] as String?,
    );
  }
}

extension StringExtension on String {
  String capitalizeFirstLetter() {
    return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
  }
}
