import 'package:flutter/material.dart';
import '../../models/maintenance_request_model.dart';
import '../technician_task_detail_screen.dart';

class TechnicianTaskCard extends StatelessWidget {
  final MaintenanceRequestModel request;

  const TechnicianTaskCard({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(request.category),
        subtitle: Text(request.location),
        trailing: Text(request.status),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  TechnicianTaskDetailScreen(
                    request: request,
                  ),
            ),
          );
        },
      ),
    );
  }
}