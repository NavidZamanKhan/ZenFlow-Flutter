import 'package:dio/dio.dart';

import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../models/category_budget_item.dart';
import '../models/expense_item.dart';

class ExpensesService {
  final ApiClient _apiClient;

  ExpensesService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  Future<List<ExpenseItem>> getExpenses() async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.expenses);
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List)
            .map((e) => ExpenseItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load expenses from server.',
      );
    }
  }

  Future<ExpenseItem> createExpense(ExpenseItem expense) async {
    try {
      final response = await _apiClient.dio.post(
        ApiEndpoints.expenses,
        data: expense.toJson(),
      );
      if (response.statusCode == 201 && response.data != null) {
        return ExpenseItem.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Failed to create expense.');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to save expense.',
      );
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _apiClient.dio.delete('${ApiEndpoints.expenses}$id/');
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to delete expense.',
      );
    }
  }

  Future<List<CategoryBudgetItem>> getBudget(
    List<ExpenseItem> expenses,
  ) async {
    try {
      final response = await _apiClient.dio.get(ApiEndpoints.budget);
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final categoryBudgets =
            (data['categoryBudgets'] as Map<String, dynamic>?) ?? {};
        final currency = data['currency']?.toString() ?? 'BDT';

        // Calculate spent amount per category from live expenses
        final spentMap = <String, double>{};
        for (final exp in expenses) {
          spentMap[exp.category] =
              (spentMap[exp.category] ?? 0.0) + exp.amount;
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

        // Add standard categories if not present in budget
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
        ];
        for (final cat in defaultCats) {
          if (!items.any((i) => i.category.toLowerCase() == cat.toLowerCase())) {
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
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to load budget details.',
      );
    }
  }

  Future<void> updateCategoryBudget({
    required String category,
    required double newAmount,
    required List<CategoryBudgetItem> currentBudgets,
  }) async {
    try {
      final categoryBudgetsMap = <String, double>{};
      double total = 0.0;

      for (final b in currentBudgets) {
        final amount = b.category == category ? newAmount : b.budgetAmount;
        if (amount > 0) {
          categoryBudgetsMap[b.category] = amount;
          total += amount;
        }
      }

      await _apiClient.dio.put(
        ApiEndpoints.budget,
        data: {
          'monthlyTotal': total,
          'categoryBudgets': categoryBudgetsMap,
          'warningThresholds': [75, 90, 100],
        },
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data?['detail'] ?? 'Failed to update category budget.',
      );
    }
  }
}
