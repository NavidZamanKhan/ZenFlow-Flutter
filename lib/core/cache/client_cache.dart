import 'dart:async';

/// In-memory SWR (Stale-While-Revalidate) session cache with pub/sub reactivity.
/// Provides 0ms instant data retrieval across tabs and screens.
class ClientCache {
  ClientCache._();
  static final ClientCache instance = ClientCache._();

  final Map<String, dynamic> _cache = {};
  final Map<String, StreamController<dynamic>> _controllers = {};

  /// Get cached data for a specific user-scoped key
  T? get<T>(String key) {
    final val = _cache[key];
    if (val is T) return val;
    return null;
  }

  /// Check if a key exists in cache
  bool has(String key) => _cache.containsKey(key);

  /// Store data in cache and notify all active subscribers
  void set<T>(String key, T data) {
    _cache[key] = data;
    if (_controllers.containsKey(key)) {
      _controllers[key]!.add(data);
    }
  }

  /// Delete a specific key from cache
  void delete(String key) {
    _cache.remove(key);
    if (_controllers.containsKey(key)) {
      _controllers[key]!.add(null);
    }
  }

  /// Clear all cached data (called on logout)
  void clear() {
    _cache.clear();
    for (final controller in _controllers.values) {
      controller.add(null);
    }
  }

  /// Stream of cache updates for a specific key
  Stream<T?> watch<T>(String key) {
    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<dynamic>.broadcast();
    }
    return _controllers[key]!.stream.map((val) => val is T ? val : null);
  }
}
