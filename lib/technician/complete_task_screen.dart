import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/maintenance_request_model.dart';
import '../providers/technician_provider.dart';

class CompleteTaskScreen extends StatefulWidget {
  final MaintenanceRequestModel request;

  const CompleteTaskScreen({
    super.key,
    required this.request,
  });

  @override
  State<CompleteTaskScreen> createState() =>
      _CompleteTaskScreenState();
}

class _CompleteTaskScreenState extends State<CompleteTaskScreen> {
  final notes = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Task")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: notes,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                    labelText: "Completion notes",
                  ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await context
                    .read<TechnicianProvider>()
                    .completeTask(
                      widget.request.id,
                      notes.text,
                    );
                if (mounted) Navigator.pop(context);
              },
              child: const Text("Submit Completion"),
            )
          ],
        ),
      ),
    );
  }
}