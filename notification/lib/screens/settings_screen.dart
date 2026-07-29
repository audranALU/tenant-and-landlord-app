import 'package:flutter/material.dart';
import '../app_colors.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/app_settings.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _service = SettingsService.instance;
  AppSettings _settings = const AppSettings();

  bool get pushNotifications => _settings.pushNotifications;
  bool get emailAlerts => _settings.emailAlerts;
  bool get darkMode => _settings.darkMode;
  bool get lowDataMode => _settings.lowDataMode;

  @override
  void initState() {
    super.initState();
    // Local-first: paint instantly from SharedPreferences, then refresh
    // from Firestore in case the user changed a setting on another device.
    _service.loadLocal().then((settings) {
      if (mounted) setState(() => _settings = settings);
    });
    _service.syncFromRemote().then((settings) {
      if (mounted) setState(() => _settings = settings);
    });
  }

  Future<void> _update(AppSettings updated) async {
    setState(() => _settings = updated);
    await _service.update(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const _SectionHeader('App Settings'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _SwitchRow(
                    icon: Icons.notifications_none_rounded,
                    title: 'Push Notifications',
                    subtitle: 'Instant updates on maintenance tasks',
                    value: pushNotifications,
                    onChanged: (v) =>
                        _update(_settings.copyWith(pushNotifications: v)),
                  ),
                  _SwitchRow(
                    icon: Icons.mail_outline,
                    title: 'Email Alerts',
                    subtitle: 'Weekly summaries and reports',
                    value: emailAlerts,
                    onChanged: (v) =>
                        _update(_settings.copyWith(emailAlerts: v)),
                  ),
                  _SwitchRow(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    subtitle: 'Switch to a low-light interface',
                    value: darkMode,
                    onChanged: (v) => _update(_settings.copyWith(darkMode: v)),
                  ),
                  _SwitchRow(
                    icon: Icons.data_usage_outlined,
                    title: 'Low Data Mode',
                    subtitle: 'Reduce data usage on mobile networks',
                    value: lowDataMode,
                    onChanged: (v) =>
                        _update(_settings.copyWith(lowDataMode: v)),
                    isLast: true,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _SectionHeader('Support'),
              const SizedBox(height: 8),
              _SettingsCard(
                children: [
                  _NavRow(icon: Icons.help_outline, title: 'Help Center'),
                  _NavRow(icon: Icons.chat_bubble_outline, title: 'Contact Us'),
                  _NavRow(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy'),
                  _NavRow(
                      icon: Icons.gavel_outlined,
                      title: 'Terms of Service',
                      isLast: true),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE7E7E5),
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.logout, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Log Out',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'App Version 2.4.1 (Build 890)',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 3,
        onTap: (i) {},
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isLast;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeThumbColor: Colors.white,
                activeTrackColor: AppColors.darkGreen,
              ),
            ],
          ),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}

class _NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isLast;

  const _NavRow({
    required this.icon,
    required this.title,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: () {},
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
          leading: Icon(icon, color: Colors.black87, size: 22),
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          trailing:
              const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ),
        if (!isLast)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Divider(height: 1, color: AppColors.divider),
          ),
      ],
    );
  }
}
