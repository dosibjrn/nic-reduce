import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final _firestore = FirebaseFirestore.instance;

  /// Returns a DocumentReference to the user data document
  DocumentReference<Map<String, dynamic>> userDoc(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  /// For example, to store or update user-specific fields
  Future<void> updateUserData(String uid, Map<String, dynamic> data) async {
    await userDoc(uid).set(data, SetOptions(merge: true));
  }

  /// Retrieve user data once
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    final snapshot = await userDoc(uid).get();
    return snapshot.data();
  }

  /// Delete the user doc (GDPR "delete my data")
  Future<void> deleteUserData(String uid) async {
    await userDoc(uid).delete();
  }
}
