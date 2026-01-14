
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
}
