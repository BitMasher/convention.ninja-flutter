library cache;

class CacheLifecycleContainer<T> {
  CacheLifecycleContainer({required this.value, required Duration lifetime})
      : _expiration = DateTime.now().add(lifetime);
  final T value;
  final DateTime _expiration;

  bool get isValid => _expiration.isAfter(DateTime.now());
}

/// {@template cache_client}
/// An in-memory cache client.
/// {@endtemplate}
class CacheClient {
  /// {@macro cache_client}
  CacheClient() : _cache = <String, Object>{};

  final Map<String, Object> _cache;
  DateTime _lastCleanup = DateTime.now();

  void _cleanup() {
    if (DateTime.now().difference(_lastCleanup).inMinutes < 20) {
      return;
    }
    _cache.removeWhere((key, value) {
      if (value is CacheLifecycleContainer) {
        return value.isValid == false;
      }
      return false;
    });
    _lastCleanup = DateTime.now();
  }

  /// Writes the provide [key], [value] pair to the in-memory cache.
  void write<T extends Object>(
      {required String key, required T value, Duration? lifetime}) {
    _cleanup();
    if (lifetime != null) {
      _cache[key] = CacheLifecycleContainer(value: value, lifetime: lifetime);
    } else {
      _cache[key] = value;
    }
  }

  /// Looks up the value for the provided [key].
  /// Defaults to `null` if no value exists for the provided key.
  T? read<T extends Object>({required String key}) {
    _cleanup();
    final value = _cache[key];
    if (value is CacheLifecycleContainer && value.isValid && value.value is T)
      return value.value;
    if (value is CacheLifecycleContainer && !value.isValid) {
      _cache.remove(key);
    }
    if (value is T) return value;
    return null;
  }

  List<T> readAll<T extends Object>() {
    _cleanup();
    var out = <T>[];
    for (var key in _cache.keys) {
      var item = this.read<T>(key: key);
      if (item != null) {
        out.add(item);
      }
    }
    return out;
  }

  void invalidate({required String key}) {
    _cleanup();
    _cache.remove(key);
  }
}
