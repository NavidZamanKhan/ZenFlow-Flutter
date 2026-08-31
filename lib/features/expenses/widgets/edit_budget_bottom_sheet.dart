import 'package:flutter/material.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';
import '../models/category_budget_item.dart';

class EditBudgetBottomSheet extends StatefulWidget {
  final CategoryBudgetItem budget;
  final ValueChanged<double> onSaved;
  const EditBudgetBottomSheet({
    super.key,
    required this.budget,
    required this.onSaved,
  });

  static Future<void> show(
    BuildContext context, {
    required CategoryBudgetItem budget,
    required ValueChanged<double> onSaved,
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EditBudgetBottomSheet(budget: budget, onSaved: onSaved),
      );

  @override
  State<EditBudgetBottomSheet> createState() => _EditBudgetBottomSheetState();
}

class _EditBudgetBottomSheetState extends State<EditBudgetBottomSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.budget.budgetAmount.toStringAsFixed(0),
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    widget.onSaved(amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final currencySymbol =
        CurrencyService.metadata[widget.budget.currency]?.symbol ??
            widget.budget.currency;

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
          const SizedBox(height: 18),
          Text(
            'Edit ${widget.budget.category} budget',
            style: AppTextStyles.headingLarge(zen.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Set a monthly spending limit for this category.',
            style: AppTextStyles.bodySmall(zen.textSecondary),
          ),
          const SizedBox(height: 20),
          ZenTextField(
            controller: _amount,
            labelText: 'Monthly limit',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(13),
              child: Text(
                currencySymbol,
                style: AppTextStyles.labelLarge(zen.accent),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ZenButton(label: 'Save budget', onPressed: _save),
        ],
      ),
    );
  }
}
