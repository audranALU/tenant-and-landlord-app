import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/maintenance_request_model.dart';

class LandlordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = "maintenance_requests";

  /// READ ALL — stream of every maintenance request, newest first
  Stream<List<MaintenanceRequestModel>> getAllRequests() {
    return _firestore
        .collection(_collection)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaintenanceRequestModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// READ FILTERED — stream filtered by status
  Stream<List<MaintenanceRequestModel>> getRequestsByStatus(String status) {
    return _firestore
        .collection(_collection)
        .where("status", isEqualTo: status)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return MaintenanceRequestModel.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// UPDATE STATUS — change request status (open, assigned, in_progress, resolved)
  Future<void> updateStatus(String requestId, String newStatus) async {
    await _firestore.collection(_collection).doc(requestId).update({
      "status": newStatus,
    });
  }

  /// UPDATE PRIORITY — change request urgency
  Future<void> updatePriority(String requestId, String newPriority) async {
    await _firestore.collection(_collection).doc(requestId).update({
      "urgency": newPriority,
    });
  }

  /// ASSIGN TECHNICIAN — assign a technician and set status to assigned
  Future<void> assignTechnician(
    String requestId,
    String technicianId,
    String technicianName,
  ) async {
    await _firestore.collection(_collection).doc(requestId).update({
      "technicianId": technicianId,
      "technicianName": technicianName,
      "status": "assigned",
      "assignedAt": FieldValue.serverTimestamp(),
    });
  }

  /// GET SINGLE REQUEST — one-time read of a specific request
  Future<MaintenanceRequestModel?> getRequestById(String requestId) async {
    final doc =
        await _firestore.collection(_collection).doc(requestId).get();
    if (doc.exists && doc.data() != null) {
      return MaintenanceRequestModel.fromMap(doc.id, doc.data()!);
    }
    return null;
  }

  /// GET TECHNICIANS — read available technicians from users collection
  Future<List<Map<String, dynamic>>> getTechnicians() async {
    final snapshot = await _firestore
        .collection("users")
        .where("role", isEqualTo: "technician")
        .get();

    return snapshot.docs.map((doc) {
      return {
        "uid": doc.id,
        "name": doc.data()["name"] ?? "Unknown",
        "email": doc.data()["email"] ?? "",
      };
    }).toList();
  }

  /// GET REQUEST COUNTS — for dashboard summary cards
  Future<Map<String, int>> getRequestCounts() async {
    final snapshot = await _firestore.collection(_collection).get();
    final docs = snapshot.docs;

    int open = 0;
    int assigned = 0;
    int inProgress = 0;
    int resolved = 0;

    for (var doc in docs) {
      final status = doc.data()["status"] ?? "";
      switch (status) {
        case "open":
          open++;
          break;
        case "assigned":
          assigned++;
          break;
        case "in_progress":
          inProgress++;
          break;
        case "resolved":
        case "completed":
          resolved++;
          break;
      }
    }

    return {
      "open": open,
      "assigned": assigned,
      "in_progress": inProgress,
      "resolved": resolved,
      "total": docs.length,
    };
  }
}
