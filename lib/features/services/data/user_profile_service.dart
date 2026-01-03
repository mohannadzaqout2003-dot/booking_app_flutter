import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileService {
  UserProfileService(this._firestore);

  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _doc(String uid) =>
      _firestore.collection('users').doc(uid);

  /// Ensures Firestore user doc exists and keeps basic fields updated.
  Future<void> ensureUserDoc({
    required User user,
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final ref = _doc(user.uid);
    final snap = await ref.get();

    final displayName = user.displayName ?? '';
    final email = user.email ?? '';
    final photoUrl = user.photoURL ?? '';

    final base = <String, dynamic>{
      'uid': user.uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!snap.exists) {
      await ref.set({
        ...base,
        'firstName': firstName ?? _guessFirstName(displayName),
        'lastName': lastName ?? _guessLastName(displayName),
        'phone': phone ?? (user.phoneNumber ?? ''),
        'createdAt': FieldValue.serverTimestamp(),
        'address': '',
        'dob': '',
        'status': '',
        'hobbies': '',
        'linkedin': '',
      }, SetOptions(merge: true));
    } else {
      await ref.set({
        ...base,
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
      }, SetOptions(merge: true));
    }
  }

  String _guessFirstName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? '' : parts.first;
  }

  String _guessLastName(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length <= 1) return '';
    return parts.sublist(1).join(' ');
  }
}
