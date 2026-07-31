import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/technician_provider.dart';
import 'widgets/technician_task_card.dart';

class TechnicianDashboard extends StatelessWidget {
  const TechnicianDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Assigned Tasks"),
      ),
      body: Consumer<TechnicianProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.tasks.isEmpty) {
            return const Center(
              child: Text("No assigned maintenance tasks"),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.tasks.length,
              itemBuilder: (context, index) {
                return TechnicianTaskCard(
                  request: provider.tasks[index],
                );
              },
            ),
          );
        },
      ),
    );
  }
}