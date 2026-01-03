import 'package:booking_app/features/profile/data/user_profile_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebaseAuthProvider =
    Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final firestoreProvider =
    Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);

/// current user stream (login/logout)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

///  user document stream that reacts to login/logout automatically
final userProfileProvider = StreamProvider<AppUserProfile?>((ref) async* {
  final auth = ref.watch(firebaseAuthProvider);
  final fs = ref.watch(firestoreProvider);

  await for (final user in auth.authStateChanges()) {
    if (user == null) {
      yield null;
      continue;
    }

    final docRef = fs.collection('users').doc(user.uid);

    //  ensure doc exists (important for social login / first time)
    final once = await docRef.get();
    if (!once.exists) {
      await docRef.set({
        'email': user.email ?? '',
        'displayName': user.displayName ?? '',
        'firstName': '',
        'lastName': '',
        'phone': user.phoneNumber ?? '',
        'photoUrl': user.photoURL ?? '',
        'address': '',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    //  now stream user doc
    yield* docRef.snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      return AppUserProfile.fromMap(doc.id, data);
    });
  }
});
