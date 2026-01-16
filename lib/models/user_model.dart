class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;
  final String? currencySymbol;
  final String? currencyCode;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
    this.currencySymbol,
    this.currencyCode,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
      currencySymbol: data['currencySymbol'],
      currencyCode: data['currencyCode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
      'currencySymbol': currencySymbol,
      'currencyCode': currencyCode,
    };
  }
}
