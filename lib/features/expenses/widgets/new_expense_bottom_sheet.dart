import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../models/expense_item.dart';

class NewExpenseBottomSheet extends StatefulWidget {
  final ValueChanged<ExpenseItem> onCreated;
  final String currency;
  final ExpenseItem? initialExpense;

  const NewExpenseBottomSheet({
    super.key,
    required this.onCreated,
    this.currency = 'BDT',
    this.initialExpense,
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<ExpenseItem> onCreated,
    String currency = 'BDT',
    ExpenseItem? initialExpense,
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => NewExpenseBottomSheet(
          onCreated: onCreated,
          currency: currency,
          initialExpense: initialExpense,
        ),
      );

  @override
  State<NewExpenseBottomSheet> createState() => _NewExpenseBottomSheetState();
}

class _NewExpenseBottomSheetState extends State<NewExpenseBottomSheet> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _notesController;
  late final TextEditingController _tagsController;
  late final TextEditingController _receiptController;

  late String _category;
  late String _paymentMethod;
  late DateTime _date;
  late bool _isRecurring;
  late String _recurringInterval;

  static const _categories = [
    'Food',
    'Bills',
    'Shopping',
    'Subscription',
    'Education',
    'Transportation',
    'Entertainment',
    'Healthcare',
    'Travel',
    'Others',
  ];

  static const _paymentMethods = [
    'Card',
    'Cash',
    'Mobile Wallet',
    'Bank Transfer',
    'Other',
  ];

  static const _recurringIntervals = ['weekly', 'monthly', 'yearly'];

  @override
  void initState() {
    super.initState();
    final e = widget.initialExpense;
    _titleController = TextEditingController(text: e?.title ?? '');
    _amountController = TextEditingController(
      text: e != null && e.amount > 0 ? e.amount.toStringAsFixed(2) : '',
    );
    _notesController = TextEditingController(text: e?.notes ?? '');
    _tagsController = TextEditingController(text: e?.tags.join(', ') ?? '');
    _receiptController = TextEditingController(text: e?.receiptImage ?? '');

    _category = e?.category ?? 'Food';
    _paymentMethod = e?.paymentMethod ?? 'Card';
    _date = e?.date ?? DateTime.now();
    _isRecurring = e?.isRecurring ?? false;
    _recurringInterval = e?.recurringInterval ?? 'monthly';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    _receiptController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  void _submit() {
    HapticFeedback.mediumImpact();
    final rawAmount = double.tryParse(_amountController.text.replaceAll(',', ''));
    final title = _titleController.text.trim();

    if (title.isEmpty || rawAmount == null || rawAmount <= 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid title and positive amount.'),
        ),
      );
      return;
    }

    final rawTags = _tagsController.text
        .split(',')
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();

    final newItem = ExpenseItem(
      id: widget.initialExpense?.id ??
          'temp-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      amount: rawAmount,
      currency: widget.currency,
      category: _category,
      date: _date,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : null,
      receiptImage: _receiptController.text.trim().isNotEmpty
          ? _receiptController.text.trim()
          : null,
      isRecurring: _isRecurring,
      recurringInterval: _isRecurring ? _recurringInterval : null,
      tags: rawTags,
    );

    widget.onCreated(newItem);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final currencySymbol =
        CurrencyService.metadata[widget.currency]?.symbol ?? widget.currency;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: zen.card,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: zen.border)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Drag Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: zen.border,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Title & Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.initialExpense != null
                      ? 'Edit expense'
                      : 'Add expense',
                  style: AppTextStyles.headingLarge(zen.textPrimary),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: zen.subtleFill,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(LucideIcons.x, size: 16, color: zen.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Title Field
            Text('Title', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _titleController,
              hintText: 'e.g. Blue Bottle Coffee',
            ),
            const SizedBox(height: 16),

            // 2. Amount & Date Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Amount (${widget.currency})',
                        style: AppTextStyles.labelMedium(zen.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      ZenTextField(
                        controller: _amountController,
                        hintText: '0.00',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            currencySymbol,
                            style: AppTextStyles.labelLarge(zen.accent),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pickDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: zen.subtleFill,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: zen.border),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat('MM/dd/yyyy').format(_date),
                                style: AppTextStyles.bodyMedium(zen.textPrimary),
                              ),
                              Icon(
                                LucideIcons.calendar,
                                size: 16,
                                color: zen.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. Category & Payment Method Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Category', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        context: context,
                        value: _category,
                        items: _categories,
                        onChanged: (val) => setState(() => _category = val),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment method', style: AppTextStyles.labelMedium(zen.textPrimary)),
                      const SizedBox(height: 6),
                      _buildDropdown(
                        context: context,
                        value: _paymentMethod,
                        items: _paymentMethods,
                        onChanged: (val) => setState(() => _paymentMethod = val),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 4. Notes (Optional)
            Text('Notes (optional)', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _notesController,
              hintText: 'Add any notes or context...',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // 5. Tags (Optional)
            Text('Tags (comma-separated)', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _tagsController,
              hintText: 'e.g. coffee, meeting, tax-deductible',
            ),
            const SizedBox(height: 16),

            // 6. Receipt Image URL (Optional)
            Text('Receipt image URL (optional)', style: AppTextStyles.labelMedium(zen.textPrimary)),
            const SizedBox(height: 6),
            ZenTextField(
              controller: _receiptController,
              hintText: 'https://...',
            ),
            const SizedBox(height: 18),

            // 7. Recurring Expense Toggle & Selector
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: zen.subtleFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: zen.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(LucideIcons.refresh_cw, size: 16, color: zen.accent),
                          const SizedBox(width: 10),
                          Text(
                            'Recurring expense',
                            style: AppTextStyles.labelMedium(zen.textPrimary),
                          ),
                        ],
                      ),
                      Switch.adaptive(
                        value: _isRecurring,
                        activeTrackColor: zen.accent,
                        onChanged: (val) {
                          HapticFeedback.selectionClick();
                          setState(() => _isRecurring = val);
                        },
                      ),
                    ],
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: _recurringIntervals.map((interval) {
                        final isSelected = _recurringInterval == interval;
                        final label = interval[0].toUpperCase() + interval.substring(1);
                        return Expanded(
                          child: GestureDetector(
                            onTap: () {
                              HapticFeedback.selectionClick();
                              setState(() => _recurringInterval = interval);
                            },
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? zen.accent : zen.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: isSelected ? zen.accent : zen.border,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: AppTextStyles.labelSmall(
                                    isSelected ? Colors.white : zen.textSecondary,
                                  ).copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 8. Bottom Action Buttons (Cancel + Add Expense)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.labelMedium(zen.textMuted),
                  ),
                ),
                const SizedBox(width: 12),
                ZenButton(
                  label: widget.initialExpense != null
                      ? 'Save changes'
                      : 'Add expense',
                  height: 42,
                  width: 140,
                  onPressed: _submit,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required BuildContext context,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    final zen = context.zenColors;
    final selectedVal = items.contains(value) ? value : items.first;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      decoration: BoxDecoration(
        color: zen.subtleFill,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: zen.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedVal,
          isExpanded: true,
          icon: Icon(LucideIcons.chevron_down, size: 16, color: zen.textMuted),
          dropdownColor: zen.card,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyMedium(zen.textPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) {
              HapticFeedback.selectionClick();
              onChanged(val);
            }
          },
        ),
      ),
    );
  }
}
