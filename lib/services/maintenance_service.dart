import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/maintenance_request_model.dart';

class MaintenanceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final String collection = "maintenance_requests";

  /// CREATE
  Future<void> createRequest(
      MaintenanceRequestModel request) async {
    await _firestore.collection(collection).add(
          request.toMap(),
        );
  }

  /// READ
  Stream<List<MaintenanceRequestModel>> getTenantRequests() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection(collection)
        .where("tenantId", isEqualTo: uid)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map(
      (snapshot) {
        return snapshot.docs.map((doc) {
          return MaintenanceRequestModel.fromMap(
            doc.id,
            doc.data(),
          );
        }).toList();
      },
    );
  }

  /// UPDATE
  Future<void> updateRequest(
      String id,
      Map<String, dynamic> data,
      ) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .update(data);
  }

  /// DELETE
  Future<void> deleteRequest(String id) async {
    await _firestore
        .collection(collection)
        .doc(id)
        .delete();
  }
}