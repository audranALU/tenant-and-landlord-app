import 'package:flutter/material.dart';
import '../services/technician_service.dart';
import '../models/maintenance_request_model.dart';

class TechnicianProvider extends ChangeNotifier {
  final TechnicianService _service = TechnicianService();

  List<MaintenanceRequestModel> tasks = [];
  bool isLoading = true;

  TechnicianProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    tasks = await _service.getAssignedTasks();
    isLoading = false;
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadTasks();
  }

  Future<void> completeTask(
      String id, String notes) async {
    await _service.completeTask(id, notes);
    await loadTasks();
  }
}