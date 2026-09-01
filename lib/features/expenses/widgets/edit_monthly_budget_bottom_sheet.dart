import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/services/currency_service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/zenflow_theme.dart';
import '../../../core/widgets/zen_button.dart';
import '../../../core/widgets/zen_text_field.dart';

class EditMonthlyBudgetBottomSheet extends StatefulWidget {
  final double currentBudget;
  final ValueChanged<double> onSaved;
  final String currency;

  const EditMonthlyBudgetBottomSheet({
    super.key,
    required this.currentBudget,
    required this.onSaved,
    this.currency = 'BDT',
  });

  static Future<void> show(
    BuildContext context, {
    required double currentBudget,
    required ValueChanged<double> onSaved,
    String currency = 'BDT',
  }) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => EditMonthlyBudgetBottomSheet(
          currentBudget: currentBudget,
          onSaved: onSaved,
          currency: currency,
        ),
      );

  @override
  State<EditMonthlyBudgetBottomSheet> createState() =>
      _EditMonthlyBudgetBottomSheetState();
}

class _EditMonthlyBudgetBottomSheetState
    extends State<EditMonthlyBudgetBottomSheet> {
  late final TextEditingController _amount = TextEditingController(
    text: widget.currentBudget > 0
        ? widget.currentBudget.round().toString()
        : '40000',
  );

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  void _save() {
    final amount = double.tryParse(_amount.text.replaceAll(',', ''));
    if (amount == null || amount <= 0) return;
    HapticFeedback.mediumImpact();
    widget.onSaved(amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final zen = context.zenColors;
    final currencySymbol =
        CurrencyService.metadata[widget.currency]?.symbol ?? widget.currency;

    final presets = widget.currency == 'BDT' ||
            widget.currency == 'JPY' ||
            widget.currency == 'INR'
        ? [20000, 30000, 40000, 50000, 75000, 100000]
        : [250, 400, 500, 750, 1000, 1500];

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
            'Edit Monthly Budget',
            style: AppTextStyles.headingLarge(zen.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            'Set your overall spending ceiling across all categories for this month.',
            style: AppTextStyles.bodySmall(zen.textSecondary),
          ),
          const SizedBox(height: 20),
          ZenTextField(
            controller: _amount,
            labelText: 'Total monthly budget',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefixIcon: Padding(
              padding: const EdgeInsets.all(13),
              child: Text(
                currencySymbol,
                style: AppTextStyles.labelLarge(zen.accent),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: presets.map((preset) {
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    _amount.text = preset.toString();
                  });
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: zen.subtleFill,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: zen.border),
                  ),
                  child: Text(
                    '$currencySymbol$preset',
                    style: AppTextStyles.labelSmall(zen.textPrimary),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          ZenButton(label: 'Save Monthly Budget', onPressed: _save),
        ],
      ),
    );
  }
}
