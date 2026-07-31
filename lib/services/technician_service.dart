import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/maintenance_request_model.dart';

class TechnicianService {
  final _db = FirebaseFirestore.instance;

  Future<List<MaintenanceRequestModel>> getAssignedTasks() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final result = await _db
        .collection("maintenance_requests")
        .where("technicianId", isEqualTo: uid)
        .get();

    return result.docs
        .map((doc) => MaintenanceRequestModel.fromMap(
              doc.id,
              doc.data(),
            ))
        .toList();
  }

  Future<void> completeTask(
      String id, String notes) async {
    await _db.collection("maintenance_requests")
        .doc(id)
        .update({
      "status": "resolved",
      "completionNotes": notes,
      "completedAt": Timestamp.now(),
    });
  }
}