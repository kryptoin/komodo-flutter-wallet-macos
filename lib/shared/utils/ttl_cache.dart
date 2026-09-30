/// Minimal in-memory TTL cache with in-flight request deduplication.
///
/// [get] returns a cached value while it is still fresh for the TTL it was
/// stored with. Otherwise it runs [fetch] — joining an identical request
/// that is already in flight for the same key instead of starting a
/// duplicate — and stores the result until [ttl] elapses.
///
/// Failures are never cached: `null` values and values rejected by
/// [cacheIf] are not stored, so the next call retries. This keeps the cache
/// transparent for callers while collapsing the burst of identical RPCs
/// that several blocs fire on the same cadence (e.g. the 10s max-volume
/// timers in the taker, maker, bridge and market-maker-bot forms).
class TtlCache<K, V> {
  TtlCache({this.name, this.defaultTtl = const Duration(seconds: 30)});

  /// Optional label used by [statsString].
  final String? name;
  final Duration defaultTtl;

  final Map<K, _TtlCacheEntry<V>> _entries = {};
  final Map<K, Future<V>> _inFlight = {};

  /// Calls served from a fresh cached value.
  int hits = 0;

  /// Calls that joined a request already in flight for the same key.
  int deduplicated = 0;

  /// Calls that had to start a fetch.
  int misses = 0;

  int get size => _entries.length;

  /// Whether [key] currently holds a non-expired value.
  bool isFresh(K key) {
    final _TtlCacheEntry<V>? entry = _entries[key];
    return entry != null && _isFresh(entry);
  }

  /// Returns the cached value for [key] if fresh, otherwise runs [fetch].
  ///
  /// [cacheIf] can veto storing a particular value (e.g. keep API errors
  /// out of the cache so a retry button works immediately).
  Future<V> get(
    K key,
    Future<V> Function() fetch, {
    Duration? ttl,
    bool Function(V value)? cacheIf,
  }) {
    final _TtlCacheEntry<V>? entry = _entries[key];
    if (entry != null && _isFresh(entry)) {
      hits += 1;
      return Future<V>.value(entry.value);
    }

    final Future<V>? pending = _inFlight[key];
    if (pending != null) {
      deduplicated += 1;
      return pending;
    }

    misses += 1;
    final Future<V> future = _fetch(key, fetch, ttl ?? defaultTtl, cacheIf);
    _inFlight[key] = future;
    return future;
  }

  /// Drops a single entry (and any in-flight fetch associated with it).
  void remove(K key) {
    _entries.remove(key);
    _inFlight.remove(key);
  }

  /// Drops all entries. Cumulative [hits]/[misses] counters are kept so
  /// long-lived sessions can still report the cache's effectiveness.
  void clear() {
    _entries.clear();
    _inFlight.clear();
  }

  String statsString() =>
      'TtlCache(${name ?? 'anon'}): hits=$hits, deduplicated=$deduplicated, '
      'misses=$misses, size=$size';

  Future<V> _fetch(
    K key,
    Future<V> Function() fetch,
    Duration ttl,
    bool Function(V value)? cacheIf,
  ) async {
    try {
      final V value = await fetch();
      if (value != null && (cacheIf?.call(value) ?? true)) {
        _entries[key] = _TtlCacheEntry<V>(
          value: value,
          expiresAt: DateTime.now().add(ttl),
        );
      }
      return value;
    } finally {
      _inFlight.remove(key);
    }
  }

  bool _isFresh(_TtlCacheEntry<V> entry) =>
      DateTime.now().isBefore(entry.expiresAt);
}

class _TtlCacheEntry<V> {
  const _TtlCacheEntry({required this.value, required this.expiresAt});

  final V value;
  final DateTime expiresAt;
}
