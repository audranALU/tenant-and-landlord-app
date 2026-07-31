import 'package:flutter/material.dart';
import '../models/maintenance_request_model.dart';
import 'complete_task_screen.dart';

class TechnicianTaskDetailScreen extends StatelessWidget {
  final MaintenanceRequestModel request;

  const TechnicianTaskDetailScreen({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Task Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.category,
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text("Location: ${request.location}"),
            Text("Urgency: ${request.urgency}"),
            Text(request.description),
            const Spacer(),
            ElevatedButton(
              child: const Text("Complete Task"),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CompleteTaskScreen(request: request),
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}