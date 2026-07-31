import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/status_badge.dart';
import '../models/maintenance_request_model.dart';
import '../providers/landlord_provider.dart';
import 'request_detail_screen.dart';

class LandlordDashboard extends StatelessWidget {
  const LandlordDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Consumer<LandlordProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(context, provider);
          }

          return CustomScrollView(
            slivers: [
              // ── Header ──
              SliverToBoxAdapter(child: _buildHeader(context)),

              // ── Summary Cards ──
              SliverToBoxAdapter(
                child: _buildSummaryCards(provider.counts),
              ),

              // ── Filter Tabs ──
              SliverToBoxAdapter(
                child: _buildFilterTabs(context, provider),
              ),

              // ── Section Title ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        provider.activeFilter == "all"
                            ? "All Requests"
                            : "${_filterLabel(provider.activeFilter)} Requests",
                        style: AppTextStyles.h3,
                      ),
                      Text(
                        "${provider.requests.length} total",
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Request List ──
              if (provider.requests.isEmpty)
                SliverToBoxAdapter(child: _buildEmptyState(provider))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _buildRequestCard(
                          context,
                          provider.requests[index],
                        );
                      },
                      childCount: provider.requests.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ── Header ──
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Landlord Dashboard",
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Property Overview",
                    style: AppTextStyles.h2Light,
                  ),
                ],
              ),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Summary Cards ──
  Widget _buildSummaryCards(Map<String, int> counts) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Row(
        children: [
          Expanded(
            child: _summaryCard(
              "Open",
              "${counts["open"] ?? 0}",
              AppColors.openBg,
              AppColors.openText,
              Icons.error_outline_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              "Assigned",
              "${counts["assigned"] ?? 0}",
              AppColors.assignedBg,
              AppColors.assignedText,
              Icons.person_add_alt_1_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              "In Progress",
              "${counts["in_progress"] ?? 0}",
              AppColors.inProgressBg,
              AppColors.inProgressText,
              Icons.autorenew_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _summaryCard(
              "Resolved",
              "${counts["resolved"] ?? 0}",
              AppColors.resolvedBg,
              AppColors.resolvedText,
              Icons.check_circle_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard(
    String label,
    String count,
    Color bg,
    Color textColor,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(height: 6),
          Text(
            count,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Filter Tabs ──
  Widget _buildFilterTabs(BuildContext context, LandlordProvider provider) {
    final filters = [
      {"id": "all", "label": "All"},
      {"id": "open", "label": "Open"},
      {"id": "assigned", "label": "Assigned"},
      {"id": "in_progress", "label": "In Progress"},
      {"id": "resolved", "label": "Resolved"},
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isActive = provider.activeFilter == f["id"];
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => provider.setFilter(f["id"]!),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.primary : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: isActive
                        ? null
                        : Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    f["label"]!,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Request Card ──
  Widget _buildRequestCard(
    BuildContext context,
    MaintenanceRequestModel request,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RequestDetailScreen(request: request),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + title + arrow
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _categoryColor(request.category).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _categoryIcon(request.category),
                    color: _categoryColor(request.category),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        request.description.length > 40
                            ? "${request.description.substring(0, 40)}..."
                            : request.description,
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${request.category} · ${request.location}",
                        style: AppTextStyles.bodySmall,
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottom row: status badge + priority + date
            Row(
              children: [
                StatusBadge(status: request.status),
                const SizedBox(width: 10),
                PriorityIndicator(
                  priority: request.urgency,
                  showLabel: true,
                ),
                const Spacer(),
                Text(
                  _formatDate(request.createdAt),
                  style: AppTextStyles.labelUppercase,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty State ──
  Widget _buildEmptyState(LandlordProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.inbox_rounded,
            size: 64,
            color: AppColors.textSecondary.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            "No ${provider.activeFilter == "all" ? "" : "${_filterLabel(provider.activeFilter)} "}requests",
            style: AppTextStyles.h3.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.activeFilter == "all"
                ? "Maintenance requests from tenants will appear here."
                : "There are no requests with this status.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Error State ──
  Widget _buildErrorState(BuildContext context, LandlordProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 8),
            Text(
              provider.error!,
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.clearError();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text("Try Again"),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──
  String _filterLabel(String filter) {
    switch (filter) {
      case "in_progress":
        return "In Progress";
      case "open":
        return "Open";
      case "assigned":
        return "Assigned";
      case "resolved":
        return "Resolved";
      default:
        return filter;
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return "";
    try {
      final date = timestamp.toDate();
      final months = [
        "Jan", "Feb", "Mar", "Apr", "May", "Jun",
        "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
      ];
      return "${months[date.month - 1]} ${date.day}";
    } catch (_) {
      return "";
    }
  }

  IconData _categoryIcon(String category) {
    switch (category.toLowerCase()) {
      case "plumbing":
        return Icons.plumbing_rounded;
      case "electrical":
        return Icons.electrical_services_rounded;
      case "structural":
        return Icons.foundation_rounded;
      case "pest":
      case "pest control":
        return Icons.pest_control_rounded;
      case "appliance":
      case "appliances":
        return Icons.kitchen_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  Color _categoryColor(String category) {
    switch (category.toLowerCase()) {
      case "plumbing":
        return AppColors.info;
      case "electrical":
        return AppColors.warning;
      case "structural":
        return const Color(0xFF8B5CF6);
      case "pest":
      case "pest control":
        return AppColors.error;
      case "appliance":
      case "appliances":
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }
}
