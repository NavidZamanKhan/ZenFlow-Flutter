import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_card.dart';
import '../models/user_profile.dart';
import 'preference_picker_sheet.dart';

class SettingsExpensePrefsCard extends StatefulWidget {
  final UserProfile profile;
  final ValueChanged<UserProfile> onSave;

  const SettingsExpensePrefsCard({
    super.key,
    required this.profile,
    required this.onSave,
  });

  @override
  State<SettingsExpensePrefsCard> createState() =>
      _SettingsExpensePrefsCardState();
}

class _SettingsExpensePrefsCardState extends State<SettingsExpensePrefsCard> {
  late String _currency;
  late String _dateFormat;
  late String _numberFormat;
  late String _firstDayOfWeek;
  late String _defaultPaymentMethod;
  late String _defaultExpenseCategory;
  late bool _is24HourTime;
  bool _isRefreshingRate = false;

  @override
  void initState() {
    super.initState();
    _currency = widget.profile.currency;
    _dateFormat = widget.profile.dateFormat;
    _numberFormat = widget.profile.numberFormat;
    _firstDayOfWeek = widget.profile.firstDayOfWeek;
    _defaultPaymentMethod = widget.profile.defaultPaymentMethod;
    _defaultExpenseCategory = widget.profile.defaultExpenseCategory;
    _is24HourTime = widget.profile.is24HourTime;
  }

  void _refreshRate() async {
    setState(() => _isRefreshingRate = true);
    HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() => _isRefreshingRate = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Exchange rates refreshed')),
      );
    }
  }

  void _save() {
    final updated = widget.profile.copyWith(
      currency: _currency,
      dateFormat: _dateFormat,
      numberFormat: _numberFormat,
      firstDayOfWeek: _firstDayOfWeek,
      defaultPaymentMethod: _defaultPaymentMethod,
      defaultExpenseCategory: _defaultExpenseCategory,
      is24HourTime: _is24HourTime,
    );
    widget.onSave(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preferences saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return ZenCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Default currency & 2. Date format
          Row(
            children: [
              Expanded(
                child: _DropdownTile(
                  label: 'Default currency',
                  value: _currency,
                  onTap: () => PreferencePickerSheet.show(
                    context,
                    title: 'Default currency',
                    options: const [
                      'BDT',
                      'USD',
                      'EUR',
                      'GBP',
                      'CAD',
                      'AUD',
                      'JPY',
                      'INR'
                    ],
                    selectedValue: _currency,
                    onSelected: (val) => setState(() => _currency = val),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownTile(
                  label: 'Date format',
                  value: _dateFormat,
                  onTap: () => PreferencePickerSheet.show(
                    context,
                    title: 'Date format',
                    options: const ['MM/DD/YYYY', 'DD/MM/YYYY', 'YYYY-MM-DD'],
                    selectedValue: _dateFormat,
                    onSelected: (val) => setState(() => _dateFormat = val),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Number format & 4. First day of week
          Row(
            children: [
              Expanded(
                child: _DropdownTile(
                  label: 'Number format',
                  value: _numberFormat,
                  onTap: () => PreferencePickerSheet.show(
                    context,
                    title: 'Number format',
                    options: const ['1,234.56', '1.234,56', '1 234,56'],
                    selectedValue: _numberFormat,
                    onSelected: (val) => setState(() => _numberFormat = val),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownTile(
                  label: 'First day of week',
                  value: _firstDayOfWeek,
                  onTap: () => PreferencePickerSheet.show(
                    context,
                    title: 'First day of week',
                    options: const ['Sunday', 'Monday', 'Saturday'],
                    selectedValue: _firstDayOfWeek,
                    onSelected: (val) => setState(() => _firstDayOfWeek = val),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 5. Default payment method & 6. Default expense category
          Row(
            children: [
              Expanded(
                child: _DropdownTile(
                  label: 'Default payment method',
                  value: _defaultPaymentMethod,
                  onTap: () => PreferencePickerSheet.show(
                    context,
                    title: 'Default payment method',
                    options: const ['Card', 'Cash', 'Mobile Wallet'],
                    selectedValue: _defaultPaymentMethod,
                    onSelected: (val) =>
                        setState(() => _defaultPaymentMethod = val),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DropdownTile(
                  label: 'Default expense category',
                  value: _defaultExpenseCategory,
                  onTap: () => PreferencePickerSheet.show(
                    context,
                    title: 'Default expense category',
                    options: const [
                      'Food',
                      'Bills',
                      'Shopping',
                      'Subscription',
                      'Education',
                      'Transportation',
                      'Healthcare',
                      'Entertainment',
                      'Travel'
                    ],
                    selectedValue: _defaultExpenseCategory,
                    onSelected: (val) =>
                        setState(() => _defaultExpenseCategory = val),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(LucideIcons.utensils, size: 13, color: zen.accent),
              const SizedBox(width: 6),
              Text(
                'Uses the same category metadata as Expenses',
                style: AppTextStyles.labelSmall(zen.textMuted).copyWith(
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Live Market Exchange Rate Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: zen.subtleFill,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: zen.border),
            ),
            child: Row(
              children: [
                Icon(LucideIcons.globe, size: 18, color: zen.accent),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Live Market Exchange Rate ',
                            style: AppTextStyles.labelMedium(zen.textPrimary)
                                .copyWith(fontWeight: FontWeight.w600),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.success.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Live',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '\$1.00 USD ≈ 123.18 BDT (01:02 AM)',
                        style: AppTextStyles.bodySmall(zen.textSecondary),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _isRefreshingRate ? null : _refreshRate,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: zen.card,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: zen.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isRefreshingRate
                            ? SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation(zen.accent),
                                ),
                              )
                            : Icon(LucideIcons.refresh_cw,
                                size: 13, color: zen.accent),
                        const SizedBox(width: 6),
                        Text(
                          'Refresh rate',
                          style: AppTextStyles.labelSmall(zen.accent)
                              .copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 24-Hour Time Switch Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('24-hour time',
                      style: AppTextStyles.bodyMedium(zen.textPrimary)),
                  const SizedBox(height: 2),
                  Text('Store times as 24-hour instead of 12-hour display.',
                      style: AppTextStyles.labelSmall(zen.textMuted)),
                ],
              ),
              Switch.adaptive(
                value: _is24HourTime,
                activeTrackColor: zen.accent,
                onChanged: (val) => setState(() => _is24HourTime = val),
              ),
            ],
          ),
          const SizedBox(height: 22),

          // Save Preferences Button
          Align(
            alignment: Alignment.centerRight,
            child: ZenButton(
              label: 'Save preferences',
              icon: LucideIcons.bookmark_check,
              height: 42,
              width: 160,
              onPressed: _save,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DropdownTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelSmall(zen.textSecondary).copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: zen.subtleFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: zen.border),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppTextStyles.bodyMedium(zen.textPrimary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(LucideIcons.chevron_down, size: 15, color: zen.textMuted),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
