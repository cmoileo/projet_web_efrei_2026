import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../constants/firestore_collections.dart';
import '../models/user_model.dart';

class UserService {
  const UserService(this._firestore);

  final FirebaseFirestore _firestore;

  Future<void> createUser(UserModel user) async {
    await _firestore
        .collection(FirestoreCollections.users)
        .doc(user.uid)
        .set(user.toFirestore());
  }

  Future<UserModel?> getUser(String uid) async {
    debugPrint('[UserService] getUser: $uid');
    final doc =
        await _firestore.collection(FirestoreCollections.users).doc(uid).get();
    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  Future<List<UserModel>> getVolunteers() async {
    final snapshot = await _firestore
        .collection(FirestoreCollections.users)
        .where('role', isEqualTo: UserRole.volunteer.value)
        .get();
    return snapshot.docs.map(UserModel.fromFirestore).toList();
  }
}
