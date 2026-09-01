import 'package:flutter_test/flutter_test.dart';
import 'package:zenflow_flutter/core/services/currency_service.dart';
import 'package:zenflow_flutter/features/expenses/models/category_budget_item.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Audit Pass 1: Budget & Currency Engine Verification', () {
    final curService = CurrencyService();

    test('Check 1: Single conversion guarantee - No double multiplication', () {
      // Budget stored in USD ($40.56)
      const budgetItem = CategoryBudgetItem(
        category: 'Entertainment',
        budgetAmount: 40.56,
        spentAmount: 2000.0, // Stored converted in BDT
        currency: 'BDT',
      );

      // When displaying in activeCurrency BDT:
      final convertedSpent = curService.convertAmount(
        amount: budgetItem.spentAmount,
        toCurrency: 'BDT',
        fromCurrency: budgetItem.currency,
      );
      final convertedBudget = curService.convertAmount(
        amount: budgetItem.budgetAmount,
        toCurrency: 'BDT',
        fromCurrency: 'USD',
        smartSnap: true,
      );

      expect(convertedSpent, 2000.0);
      expect(convertedBudget, 5000.0); // Snapped from 4999.8 -> 5000.0
      final percentUsed = ((convertedSpent / convertedBudget) * 100).round();
      expect(percentUsed, 40); // 40%, NOT 4931%!
    });

    test('Check 2: Floating point drift elimination (Snap tests)', () {
      const liveRateBDT = 123.27;

      // 40,000 BDT -> USD -> BDT
      final inUSD_40k = 40000.0 / liveRateBDT; // 324.49095...
      final backToBDT_40k = inUSD_40k * liveRateBDT;
      final snapped40k = CurrencyService.smartConvertCurrency(
        backToBDT_40k,
        toCurrency: 'BDT',
      );
      expect(snapped40k, 40000.0);

      // 20,000 BDT -> USD -> BDT (was drifting to 19,947.14)
      final inUSD_20k = 161.815;
      final backToBDT_20k = inUSD_20k * liveRateBDT; // 19947.14
      final snapped20k = CurrencyService.smartConvertCurrency(
        backToBDT_20k,
        toCurrency: 'BDT',
      );
      expect(snapped20k, 20000.0);

      // 10,000 BDT -> USD -> BDT (was drifting to 9,973.57)
      final inUSD_10k = 80.908;
      final backToBDT_10k = inUSD_10k * liveRateBDT; // 9973.57
      final snapped10k = CurrencyService.smartConvertCurrency(
        backToBDT_10k,
        toCurrency: 'BDT',
      );
      expect(snapped10k, 10000.0);

      // 5,000 BDT -> USD -> BDT (was drifting to 4,994.17)
      final inUSD_5k = 40.514;
      final backToBDT_5k = inUSD_5k * liveRateBDT; // 4994.17
      final snapped5k = CurrencyService.smartConvertCurrency(
        backToBDT_5k,
        toCurrency: 'BDT',
      );
      expect(snapped5k, 5000.0);

      // 2,000 BDT -> USD -> BDT (was drifting to 1,970.09)
      final inUSD_2k = 15.9819;
      final backToBDT_2k = inUSD_2k * liveRateBDT; // 1970.09
      final snapped2k = CurrencyService.smartConvertCurrency(
        backToBDT_2k,
        toCurrency: 'BDT',
      );
      expect(snapped2k, 2000.0);
    });

    test('Check 3: All 8 currency formats and symbols', () {
      expect(
        curService.formatMoney(amount: 1500.50, currency: 'BDT'),
        '৳1,500.50',
      );
      expect(
        curService.formatMoney(amount: 1500.50, currency: 'USD'),
        '\$1,500.50',
      );
      expect(
        curService.formatMoney(amount: 1500.50, currency: 'EUR'),
        '€1,500.50',
      );
      expect(
        curService.formatMoney(amount: 1500.50, currency: 'GBP'),
        '£1,500.50',
      );
      expect(
        curService.formatMoney(amount: 1500.50, currency: 'INR'),
        '₹1,500.50',
      );
      expect(
        curService.formatMoney(amount: 1500.00, currency: 'JPY'),
        '¥1,500',
      );
      expect(
        curService.formatMoney(amount: 1500.50, currency: 'CAD'),
        'CA\$1,500.50',
      );
      expect(
        curService.formatMoney(amount: 1500.50, currency: 'AUD'),
        'AU\$1,500.50',
      );
    });
  });
}
