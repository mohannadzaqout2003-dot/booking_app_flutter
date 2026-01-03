class AppUserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String firstName;
  final String lastName;
  final String phone;
  final String photoUrl;
  final String address;

  const AppUserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.photoUrl,
    required this.address,
  });

  factory AppUserProfile.fromMap(String uid, Map<String, dynamic> map) {
    return AppUserProfile(
      uid: uid,
      email: (map['email'] ?? '').toString(),
      displayName: (map['displayName'] ?? '').toString(),
      firstName: (map['firstName'] ?? '').toString(),
      lastName: (map['lastName'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      photoUrl: (map['photoUrl'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
      'photoUrl': photoUrl,
      'address': address,
    };
  }

  String get fullName {
    final n = ('${firstName.trim()} ${lastName.trim()}').trim();
    return n.isEmpty ? displayName : n;
  }
}
