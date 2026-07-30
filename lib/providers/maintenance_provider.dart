import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/maintenance_request_model.dart';
import '../services/maintenance_service.dart';

class MaintenanceProvider extends ChangeNotifier {
  final MaintenanceService _service = MaintenanceService();

  // ── State ──
  List<MaintenanceRequestModel> _requests = [];
  bool _isLoading = true;
  String? _error;
  StreamSubscription? _subscription;

  // ── Getters ──
  List<MaintenanceRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get openCount =>
      _requests.where((r) => r.status == "open").length;
  int get activeCount => _requests
      .where((r) => r.status == "open" || r.status == "assigned" || r.status == "in_progress")
      .length;

  // ── Lifecycle ──
  MaintenanceProvider() {
    _listenToRequests();
  }

  void _listenToRequests() {
    _isLoading = true;
    _error = null;

    // Only listen if a user is logged in
    if (FirebaseAuth.instance.currentUser == null) {
      _isLoading = false;
      _requests = [];
      notifyListeners();
      return;
    }

    _subscription = _service.getTenantRequests().listen(
      (requests) {
        _requests = requests;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _error = "Failed to load requests: $e";
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // ── Actions ──

  /// Create a new maintenance request
  Future<bool> createRequest({
    required String category,
    required String urgency,
    required String location,
    required String description,
    String imageUrl = "",
  }) async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final request = MaintenanceRequestModel(
        id: "", // Firestore generates the id
        tenantId: uid,
        category: category,
        urgency: urgency,
        location: location,
        description: description,
        imageUrl: imageUrl,
        status: "open",
        createdAt: Timestamp.now(),
      );

      await _service.createRequest(request);
      return true;
    } catch (e) {
      _error = "Failed to create request: $e";
      notifyListeners();
      return false;
    }
  }

  /// Update an existing request (edit description, urgency, etc.)
  Future<bool> updateRequest(String id, Map<String, dynamic> data) async {
    try {
      await _service.updateRequest(id, data);
      return true;
    } catch (e) {
      _error = "Failed to update request: $e";
      notifyListeners();
      return false;
    }
  }

  /// Cancel/delete a request
  Future<bool> deleteRequest(String id) async {
    try {
      await _service.deleteRequest(id);
      return true;
    } catch (e) {
      _error = "Failed to delete request: $e";
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
