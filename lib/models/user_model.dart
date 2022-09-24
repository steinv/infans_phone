class UserModel {

  final String id;
  final String? address;
  final bool? agreeTermsAndConditions;
  final List<String>? appointments;
  final String? email;
  final String? name;
  final String? phonenumber;
  final String? photoURL;
  final String? stripe_id;
  final String? surname;

  UserModel(this.id, this.address, this.agreeTermsAndConditions, this.appointments, this.email, this.name, this.phonenumber, this.photoURL, this.stripe_id, this.surname);

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