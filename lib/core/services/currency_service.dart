import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class CurrencyMeta {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final int fractionDigits;

  const CurrencyMeta({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.fractionDigits,
  });
}

class ExchangeRatesData {
  final String base;
  final Map<String, double> rates;
  final String lastUpdated;
  final bool isLive;

  const ExchangeRatesData({
    required this.base,
    required this.rates,
    required this.lastUpdated,
    required this.isLive,
  });
}

class CurrencyService {
  static const String _cacheKey = 'zenflow_exchange_rates_v1';
  static const Duration _cacheTtl = Duration(hours: 12);

  final Dio _dio;
  final FlutterSecureStorage _storage;

  CurrencyService({Dio? dio, FlutterSecureStorage? storage})
      : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage();

  static const Map<String, CurrencyMeta> metadata = {
    'BDT': CurrencyMeta(
      code: 'BDT',
      name: 'Bangladeshi Taka',
      symbol: '৳',
      flag: '🇧🇩',
      fractionDigits: 2,
    ),
    'USD': CurrencyMeta(
      code: 'USD',
      name: 'US Dollar',
      symbol: '\$',
      flag: '🇺🇸',
      fractionDigits: 2,
    ),
    'EUR': CurrencyMeta(
      code: 'EUR',
      name: 'Euro',
      symbol: '€',
      flag: '🇪🇺',
      fractionDigits: 2,
    ),
    'GBP': CurrencyMeta(
      code: 'GBP',
      name: 'British Pound',
      symbol: '£',
      flag: '🇬🇧',
      fractionDigits: 2,
    ),
    'INR': CurrencyMeta(
      code: 'INR',
      name: 'Indian Rupee',
      symbol: '₹',
      flag: '🇮🇳',
      fractionDigits: 2,
    ),
    'JPY': CurrencyMeta(
      code: 'JPY',
      name: 'Japanese Yen',
      symbol: '¥',
      flag: '🇯🇵',
      fractionDigits: 0,
    ),
    'CAD': CurrencyMeta(
      code: 'CAD',
      name: 'Canadian Dollar',
      symbol: 'CA\$',
      flag: '🇨🇦',
      fractionDigits: 2,
    ),
    'AUD': CurrencyMeta(
      code: 'AUD',
      name: 'Australian Dollar',
      symbol: 'AU\$',
      flag: '🇦🇺',
      fractionDigits: 2,
    ),
  };

  static const Map<String, double> fallbackRatesUsdBase = {
    'USD': 1.0,
    'BDT': 123.18,
    'EUR': 0.92,
    'GBP': 0.79,
    'INR': 86.50,
    'JPY': 154.20,
    'CAD': 1.38,
    'AUD': 1.52,
  };

  Future<ExchangeRatesData> fetchExchangeRates({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      try {
        final cachedRaw = await _storage.read(key: _cacheKey);
        if (cachedRaw != null && cachedRaw.isNotEmpty) {
          final parsed = jsonDecode(cachedRaw);
          final timestamp = DateTime.tryParse(parsed['timestamp'] ?? '');
          if (timestamp != null &&
              DateTime.now().difference(timestamp) < _cacheTtl) {
            final rawRates = parsed['rates'] as Map<String, dynamic>?;
            if (rawRates != null && rawRates.containsKey('BDT')) {
              final rates = rawRates.map(
                (k, v) => MapEntry(k, (v as num).toDouble()),
              );
              return ExchangeRatesData(
                base: 'USD',
                rates: rates,
                lastUpdated: parsed['lastUpdated'] ??
                    DateFormat('hh:mm a').format(timestamp),
                isLive: true,
              );
            }
          }
        }
      } catch (_) {}
    }

    try {
      final response = await _dio.get(
        'https://open.er-api.com/v6/latest/USD',
        options: Options(
          sendTimeout: const Duration(seconds: 6),
          receiveTimeout: const Duration(seconds: 6),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data is Map<String, dynamic>
            ? response.data as Map<String, dynamic>
            : jsonDecode(response.data.toString()) as Map<String, dynamic>;

        final rawRates = data['rates'] as Map<String, dynamic>?;
        if (rawRates != null) {
          final liveRates = <String, double>{
            'USD': 1.0,
            'BDT': (rawRates['BDT'] as num?)?.toDouble() ??
                fallbackRatesUsdBase['BDT']!,
            'EUR': (rawRates['EUR'] as num?)?.toDouble() ??
                fallbackRatesUsdBase['EUR']!,
            'GBP': (rawRates['GBP'] as num?)?.toDouble() ??
                fallbackRatesUsdBase['GBP']!,
            'INR': (rawRates['INR'] as num?)?.toDouble() ??
                fallbackRatesUsdBase['INR']!,
            'JPY': (rawRates['JPY'] as num?)?.toDouble() ??
                fallbackRatesUsdBase['JPY']!,
            'CAD': (rawRates['CAD'] as num?)?.toDouble() ??
                fallbackRatesUsdBase['CAD']!,
            'AUD': (rawRates['AUD'] as num?)?.toDouble() ??
                fallbackRatesUsdBase['AUD']!,
          };

          final now = DateTime.now();
          final timeStr = DateFormat('hh:mm a').format(now);

          await _storage.write(
            key: _cacheKey,
            value: jsonEncode({
              'timestamp': now.toIso8601String(),
              'lastUpdated': timeStr,
              'rates': liveRates,
            }),
          );

          return ExchangeRatesData(
            base: 'USD',
            rates: liveRates,
            lastUpdated: timeStr,
            isLive: true,
          );
        }
      }
    } catch (_) {}

    return ExchangeRatesData(
      base: 'USD',
      rates: fallbackRatesUsdBase,
      lastUpdated: DateFormat('hh:mm a').format(DateTime.now()),
      isLive: false,
    );
  }

  double convertAmount({
    required double amount,
    required String toCurrency,
    String fromCurrency = 'USD',
    Map<String, double>? rates,
  }) {
    if (fromCurrency == toCurrency || amount == 0) return amount;
    final r = rates ?? fallbackRatesUsdBase;
    final fromRate = r[fromCurrency] ?? 1.0;
    final toRate = r[toCurrency] ?? 1.0;
    final inUsd = amount / fromRate;
    return inUsd * toRate;
  }

  String formatMoney({
    required double amount,
    String currency = 'BDT',
    String? fromCurrency,
    Map<String, double>? rates,
  }) {
    final converted = fromCurrency != null && fromCurrency != currency
        ? convertAmount(
            amount: amount,
            toCurrency: currency,
            fromCurrency: fromCurrency,
            rates: rates,
          )
        : amount;

    final meta = metadata[currency] ?? metadata['BDT']!;
    final formattedNum = NumberFormat.currency(
      symbol: '',
      decimalDigits: meta.fractionDigits,
    ).format(converted.abs()).trim();

    final prefix = converted < 0 ? '-' : '';
    return '$prefix${meta.symbol}$formattedNum';
  }
}
