import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/services/currency_service.dart';
import '../models/category_budget_item.dart';
import '../models/expense_item.dart';

class ExpensesService {
  final ApiClient _apiClient;

  ExpensesService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<ExpenseItem>> getExpenses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.expenses);
      final records = _extractList(response.data);
      return records.map(ExpenseItem.fromJson).toList();
    } catch (_) {
      return [];
    }
  }

  Future<ExpenseItem> createExpense(ExpenseItem expense) async {
    try {
      final payload = expense.toJson(includeId: false);
      final response = await _apiClient.dio.post(
        ApiEndpoints.expenses,
        data: payload,
      );
      if (response.data is Map) {
        return ExpenseItem.fromJson(
          Map<String, dynamic>.from(response.data as Map),
        );
      }
      throw Exception('Failed to create expense.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to save expense on cloud.',
      );
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.expenses}$id/');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to delete expense from cloud.',
      );
    }
  }

  Future<List<CategoryBudgetItem>> getBudget(
    List<ExpenseItem> expenses,
  ) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.budget);
      if (response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final rawBudgets = data['categoryBudgets'] ?? data['category_budgets'];
        final categoryBudgets = rawBudgets is Map
            ? Map<String, dynamic>.from(rawBudgets)
            : <String, dynamic>{};
        final currency = data['currency']?.toString() ?? 'BDT';

        // Calculate spent amount per category for current month, converting each expense to budget currency
        final now = DateTime.now();
        final currentMonthExpenses = expenses.where((e) =>
            e.date.year == now.year && e.date.month == now.month);

        final spentMap = <String, double>{};
        final curService = CurrencyService();

        for (final exp in currentMonthExpenses) {
          final convertedExpAmount = curService.convertAmount(
            amount: exp.amount,
            toCurrency: currency,
            fromCurrency: exp.currency,
          );
          spentMap[exp.category] =
              (spentMap[exp.category] ?? 0.0) + convertedExpAmount;
        }

        final items = <CategoryBudgetItem>[];
        categoryBudgets.forEach((category, budgetVal) {
          final bAmt = (budgetVal is num)
              ? budgetVal.toDouble()
              : double.tryParse(budgetVal.toString()) ?? 0.0;
          items.add(
            CategoryBudgetItem(
              category: category,
              budgetAmount: bAmt,
              spentAmount: spentMap[category] ?? 0.0,
              currency: currency,
            ),
          );
        });

        const defaultCats = [
          'Bills',
          'Food',
          'Shopping',
          'Subscription',
          'Education',
          'Transportation',
          'Healthcare',
          'Entertainment',
          'Travel',
          'Others',
        ];
        for (final cat in defaultCats) {
          if (!items
              .any((i) => i.category.toLowerCase() == cat.toLowerCase())) {
            items.add(
              CategoryBudgetItem(
                category: cat,
                budgetAmount: 0.0,
                spentAmount: spentMap[cat] ?? 0.0,
                currency: currency,
              ),
            );
          }
        }

        return items;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<double> getMonthlyBudgetTotal() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.budget);
      if (response.data is Map) {
        final data = Map<String, dynamic>.from(response.data as Map);
        final rawMonthly = data['monthlyTotal'] ?? data['monthly_total'];
        if (rawMonthly is num) return rawMonthly.toDouble();
        return double.tryParse(rawMonthly?.toString() ?? '40000') ?? 40000.0;
      }
      return 40000.0;
    } catch (_) {
      return 40000.0;
    }
  }

  Future<void> updateCategoryBudget({
    required String category,
    required double newAmount,
    required List<CategoryBudgetItem> currentBudgets,
    required String currency,
    required double currentMonthlyTotal,
  }) async {
    try {
      final categoryBudgetsMap = <String, double>{};

      for (final b in currentBudgets) {
        final amount = b.category == category ? newAmount : b.budgetAmount;
        if (amount > 0) {
          categoryBudgetsMap[b.category] = amount;
        }
      }

      await _apiClient.dio.put(
        ApiEndpoints.budget,
        data: {
          'monthlyTotal': currentMonthlyTotal > 0 ? currentMonthlyTotal : 40000.0,
          'currency': currency,
          'categoryBudgets': categoryBudgetsMap,
          'warningThresholds': [75, 90, 100],
        },
      );
    } catch (_) {
      // Ignored
    }
  }

  Future<void> updateMonthlyBudgetTotal({
    required double newTotal,
    required String currency,
    required List<CategoryBudgetItem> currentBudgets,
  }) async {
    try {
      final categoryBudgetsMap = <String, double>{};

      for (final b in currentBudgets) {
        if (b.budgetAmount > 0) {
          categoryBudgetsMap[b.category] = b.budgetAmount;
        }
      }

      await _apiClient.dio.put(
        ApiEndpoints.budget,
        data: {
          'monthlyTotal': newTotal,
          'currency': currency,
          'categoryBudgets': categoryBudgetsMap,
          'warningThresholds': [75, 90, 100],
        },
      );
    } catch (_) {
      // Ignored
    }
  }

  List<Map<String, dynamic>> _extractList(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map>()
          .map((m) => Map<String, dynamic>.from(m))
          .toList();
    }
    if (data is Map) {
      final records = data['results'] ?? data['data'] ?? data['expenses'];
      if (records is List) {
        return records
            .whereType<Map>()
            .map((m) => Map<String, dynamic>.from(m))
            .toList();
      }
    }
    return [];
  }
}
