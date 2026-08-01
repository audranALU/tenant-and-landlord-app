import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../../screens/login_screen.dart';

// Role dashboards
import '../../tenant/tenant_dashboard.dart';
import '../../landlord/landlord_dashboard.dart';
// import '../../technician/technician_dashboard.dart'; // uncomment when Ella's screen exists

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    // Not logged in → login screen
    if (auth.user == null) {
      return const LoginScreen();
    }

    // Logged in but still fetching the role document
    // OPTIMIZATION: Show the default dashboard immediately instead of a spinner
    // The role will update in the background and rebuild if needed
    if (auth.loadingRole && auth.role == null) {
      // Show tenant dashboard as optimistic default while loading
      // This provides immediate feedback instead of a blocking spinner
      return const TenantDashboard(optimisticMode: true);
    }

    // Route based on role
    switch (auth.role) {
      case "landlord":
        return const LandlordDashboard();
      case "technician":
        // return const TechnicianDashboard(); // swap in when ready
        return const _RolePlaceholder(role: "Technician");
      case "tenant":
      default:
        return const TenantDashboard();
    }
  }
}

/// Temporary placeholder shown until a role's dashboard is built.
class _RolePlaceholder extends StatelessWidget {
  final String role;
  const _RolePlaceholder({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Text("$role dashboard coming soon"),
      ),
    );
  }
}
