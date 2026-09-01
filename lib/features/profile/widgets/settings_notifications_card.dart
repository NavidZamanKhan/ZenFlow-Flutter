import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_card.dart';
import '../../../core/widgets/zen_switch.dart';
import '../../notifications/models/notification_preferences.dart';
import '../../notifications/services/notification_preferences_service.dart';

class SettingsNotificationsCard extends StatefulWidget {
  const SettingsNotificationsCard({super.key});

  @override
  State<SettingsNotificationsCard> createState() =>
      _SettingsNotificationsCardState();
}

class _SettingsNotificationsCardState extends State<SettingsNotificationsCard> {
  final _prefsService = NotificationPreferencesService();
  NotificationPreferences _prefs = const NotificationPreferences();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await _prefsService.getPreferences();
    if (mounted) {
      setState(() {
        _prefs = p;
        _isLoading = false;
      });
    }
  }

  Future<void> _update(NotificationPreferences newPrefs) async {
    setState(() => _prefs = newPrefs);
    await _prefsService.savePreferences(newPrefs);
  }

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      final dt = DateTime(2026, 1, 1, hour, minute);
      final period = dt.hour >= 12 ? 'PM' : 'AM';
      final h = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      return '$h:$m $period';
    } catch (_) {
      return time24;
    }
  }

  Future<void> _pickDigestTime() async {
    final parts = _prefs.digestTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.tryParse(parts.firstOrNull ?? '9') ?? 9,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        final zen = context.zenColors;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: zen.accent,
              surface: zen.card,
              onSurface: zen.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final h = picked.hour.toString().padLeft(2, '0');
      final m = picked.minute.toString().padLeft(2, '0');
      await _update(_prefs.copyWith(digestTime: '$h:$m'));
    }
  }

  Future<void> _sendTestNotification() async {
    HapticFeedback.lightImpact();
    await NotificationService().requestPermissions();
    await NotificationService().showInstantNotification(
      id: 9999,
      title: 'ZenFlow Focus Alert ⚡',
      body: 'Your notifications are configured perfectly! Timely alerts will appear 15m before deadlines.',
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Test notification sent to lock screen!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    if (_isLoading) {
      return const SizedBox.shrink();
    }

    return ZenCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.bell, size: 18, color: zen.accent),
              const SizedBox(width: 8),
              Text(
                'Notification Preferences',
                style: AppTextStyles.headingSmall(zen.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Configure on-device alerts and daily morning focus digests.',
            style: AppTextStyles.bodySmall(zen.textSecondary),
          ),
          const SizedBox(height: 16),

          // 1. Task Deadlines Toggle
          _ToggleRow(
            title: 'Task Deadlines',
            subtitle: '15-minute alert before scheduled due times',
            icon: LucideIcons.list_todo,
            value: _prefs.tasksEnabled,
            onChanged: (val) => _update(_prefs.copyWith(tasksEnabled: val)),
          ),
          const Divider(height: 20),

          // 2. Calendar Events Toggle
          _ToggleRow(
            title: 'Calendar Events',
            subtitle: '15-minute alert before scheduled events',
            icon: LucideIcons.calendar_days,
            value: _prefs.calendarEnabled,
            onChanged: (val) => _update(_prefs.copyWith(calendarEnabled: val)),
          ),
          const Divider(height: 20),

          // 3. Budget Threshold Warnings Toggle
          _ToggleRow(
            title: 'Budget Warnings',
            subtitle: 'Alerts when monthly spending reaches 80% or 100%',
            icon: LucideIcons.shield_alert,
            value: _prefs.budgetEnabled,
            onChanged: (val) => _update(_prefs.copyWith(budgetEnabled: val)),
          ),
          const Divider(height: 20),

          // 4. Daily Morning Digest Toggle & Time
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: zen.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(LucideIcons.sun, size: 16, color: zen.accent),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Morning Digest',
                      style: AppTextStyles.labelLarge(zen.textPrimary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Daily briefing of today\'s focus & agenda',
                      style: AppTextStyles.bodySmall(zen.textSecondary),
                    ),
                  ],
                ),
              ),
              ZenSwitch(
                value: _prefs.digestEnabled,
                onChanged: (val) => _update(_prefs.copyWith(digestEnabled: val)),
              ),
            ],
          ),

          if (_prefs.digestEnabled) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDigestTime,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: zen.subtleFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: zen.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Digest Time',
                      style: AppTextStyles.bodyMedium(zen.textPrimary),
                    ),
                    Row(
                      children: [
                        Text(
                          _formatTime(_prefs.digestTime),
                          style: AppTextStyles.labelLarge(zen.accent).copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(LucideIcons.chevron_right,
                            size: 16, color: zen.textMuted),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],

          const Divider(height: 24),

          // Send Test Notification Button
          Center(
            child: TextButton.icon(
              onPressed: _sendTestNotification,
              icon: Icon(LucideIcons.send, size: 14, color: zen.accent),
              label: Text(
                'Send Test Notification',
                style: AppTextStyles.labelMedium(zen.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: zen.accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: zen.accent),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.labelLarge(zen.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.bodySmall(zen.textSecondary),
              ),
            ],
          ),
        ),
        ZenSwitch(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
