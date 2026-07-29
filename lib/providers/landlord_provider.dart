import 'dart:async';
import 'package:flutter/material.dart';
import '../models/maintenance_request_model.dart';
import '../services/landlord_service.dart';

class LandlordProvider extends ChangeNotifier {
  final LandlordService _service = LandlordService();

  // ── State ──
  List<MaintenanceRequestModel> _allRequests = [];
  List<Map<String, dynamic>> _technicians = [];
  Map<String, int> _counts = {};
  bool _isLoading = true;
  String? _error;
  String _activeFilter = "all";
  StreamSubscription? _subscription;

  // ── Getters ──
  List<MaintenanceRequestModel> get requests => _filteredRequests;
  List<MaintenanceRequestModel> get allRequests => _allRequests;
  List<Map<String, dynamic>> get technicians => _technicians;
  Map<String, int> get counts => _counts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get activeFilter => _activeFilter;

  List<MaintenanceRequestModel> get _filteredRequests {
    if (_activeFilter == "all") return _allRequests;
    return _allRequests
        .where((r) => r.status.toLowerCase() == _activeFilter)
        .toList();
  }

  // ── Lifecycle ──
  LandlordProvider() {
    _init();
  }

  void _init() {
    _isLoading = true;
    _error = null;

    _subscription = _service.getAllRequests().listen(
      (requests) {
        _allRequests = requests;
        _isLoading = false;
        _error = null;
        _updateCounts();
        notifyListeners();
      },
      onError: (e) {
        _error = "Failed to load requests: $e";
        _isLoading = false;
        notifyListeners();
      },
    );

    _loadTechnicians();
  }

  void _updateCounts() {
    int open = 0;
    int assigned = 0;
    int inProgress = 0;
    int resolved = 0;

    for (var r in _allRequests) {
      switch (r.status.toLowerCase()) {
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

    _counts = {
      "open": open,
      "assigned": assigned,
      "in_progress": inProgress,
      "resolved": resolved,
      "total": _allRequests.length,
    };
  }

  Future<void> _loadTechnicians() async {
    try {
      _technicians = await _service.getTechnicians();
      notifyListeners();
    } catch (e) {
      debugPrint("Error loading technicians: $e");
    }
  }

  // ── Actions ──
  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  Future<bool> updateStatus(String requestId, String newStatus) async {
    try {
      await _service.updateStatus(requestId, newStatus);
      return true;
    } catch (e) {
      _error = "Failed to update status: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePriority(String requestId, String newPriority) async {
    try {
      await _service.updatePriority(requestId, newPriority);
      return true;
    } catch (e) {
      _error = "Failed to update priority: $e";
      notifyListeners();
      return false;
    }
  }

  Future<bool> assignTechnician(
    String requestId,
    String technicianId,
    String technicianName,
  ) async {
    try {
      await _service.assignTechnician(
        requestId,
        technicianId,
        technicianName,
      );
      return true;
    } catch (e) {
      _error = "Failed to assign technician: $e";
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshTechnicians() async {
    await _loadTechnicians();
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
