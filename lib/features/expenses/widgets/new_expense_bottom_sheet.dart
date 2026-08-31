import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../models/expense_item.dart';

class NewExpenseBottomSheet extends StatefulWidget {
  final ValueChanged<ExpenseItem> onCreated;
  final String currency;

  const NewExpenseBottomSheet({
    super.key,
    required this.onCreated,
    this.currency = 'BDT',
  });

  static Future<void> show(
    BuildContext context, {
    required ValueChanged<ExpenseItem> onCreated,
    String currency = 'BDT',
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => NewExpenseBottomSheet(
          onCreated: onCreated,
          currency: currency,
        ),
      );

  @override
  State<NewExpenseBottomSheet> createState() => _NewExpenseBottomSheetState();
}

class _NewExpenseBottomSheetState extends State<NewExpenseBottomSheet> {
  final _amount = TextEditingController();
  final _title = TextEditingController();
  String _category = 'Bills';
  String _method = 'Card';
  DateTime _date = DateTime.now();

  static const _categories = [
    'Bills',
    'Shopping',
    'Subscription',
    'Education',
    'Food',
    'Transportation',
    'Entertainment',
  ];

  static const _methods = ['Card', 'Cash', 'Mobile Wallet'];

  @override
  void dispose() {
    _amount.dispose();
    _title.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
    if (amount == null || amount <= 0 || _title.text.trim().isEmpty) return;
    widget.onCreated(
      ExpenseItem(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        title: _title.text.trim(),
        amount: amount,
        currency: widget.currency,
        category: _category,
        date: _date,
        paymentMethod: _method,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final currencySymbol =
        CurrencyService.metadata[widget.currency]?.symbol ??
            widget.currency;

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
            Row(
              children: [
                Text(
                  'Add expense',
                  style: AppTextStyles.headingLarge(zen.textPrimary),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(LucideIcons.x, size: 19, color: zen.textMuted),
                ),
              ],
            ),
            ZenTextField(
              controller: _amount,
              labelText: 'Amount',
              hintText: '0.00',
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(13),
                child: Text(
                  currencySymbol,
                  style: AppTextStyles.labelLarge(zen.accent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ZenTextField(
              controller: _title,
              labelText: 'Title',
              hintText: 'e.g. Grocery shopping',
            ),
            const SizedBox(height: 16),
            Text(
              'Category',
              style: AppTextStyles.labelMedium(zen.textSecondary),
            ),
            const SizedBox(height: 7),
            _select(
              context,
              _categories,
              _category,
              (value) => setState(() => _category = value),
            ),
            const SizedBox(height: 16),
            Text(
              'Payment method',
              style: AppTextStyles.labelMedium(zen.textSecondary),
            ),
            const SizedBox(height: 7),
            _select(
              context,
              _methods,
              _method,
              (value) => setState(() => _method = value),
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _pickDate,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: zen.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: zen.border),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 17, color: zen.accent),
                    const SizedBox(width: 9),
                    Text(
                      '${_date.year}-${_date.month.toString().padLeft(2, '0')}-${_date.day.toString().padLeft(2, '0')}',
                      style: AppTextStyles.bodyMedium(zen.textPrimary),
                    ),
                    const Spacer(),
                    Icon(
                      LucideIcons.chevron_down,
                      size: 16,
                      color: zen.textMuted,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            ZenButton(label: 'Save expense', onPressed: _submit),
          ],
        ),
      ),
    );
  }

  Widget _select(
    BuildContext context,
    List<String> items,
    String value,
    ValueChanged<String> onChanged,
  ) {
    final zen = context.zenColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: zen.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: zen.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(LucideIcons.chevron_down, size: 16, color: zen.textMuted),
          dropdownColor: zen.surface,
          items: items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: AppTextStyles.bodyMedium(zen.textPrimary),
                  ),
                ),
              )
              .toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
        ),
      ),
    );
  }
}
