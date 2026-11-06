
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> createUserProfile(User user) async {
    final userRef = _firestore
        .collection('users')
        .doc(user.uid);

    final userDoc = await userRef.get();

    // Only create a profile if one does not already exist.
    // This preserves staff roles assigned by an administrator.
    if (!userDoc.exists) {
      await userRef.set({
        'uid': user.uid,
        'email': user.email,
        'role': 'student',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserProfile(
    String uid,
  ) {
    return _firestore
        .collection('users')
        .doc(uid)
        .get();
  }

  Future<String> getUserRole(String uid) async {
    final userDoc = await getUserProfile(uid);

    if (!userDoc.exists) {
      return 'student';
    }

    return userDoc.data()?['role'] as String? ?? 'student';
  }
}
