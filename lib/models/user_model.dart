class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? currencySymbol;
  final String? currencyCode;
  final String? phoneNumber;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.currencySymbol,
    this.currencyCode,
    this.phoneNumber,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      currencySymbol: data['currencySymbol'],
      currencyCode: data['currencyCode'],
      phoneNumber: data['phoneNumber'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'currencySymbol': currencySymbol,
      'currencyCode': currencyCode,
      'phoneNumber': phoneNumber,
    };
  }
}
