import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class FakeBox<T> implements Box<T> {
  FakeBox({
    Map<dynamic, T>? initialValues,
    this.name = 'fake_box',
    this.path,
    this.lazy = false,
    this.onAdd,
    this.onAddAll,
    this.onClear,
    this.onClose,
    this.onCompact,
    this.onContainsKey,
    this.onDelete,
    this.onDeleteAt,
    this.onDeleteAll,
    this.onDeleteFromDisk,
    this.onFlush,
    this.onGet,
    this.onGetAt,
    this.onKeyAt,
    this.onPut,
    this.onPutAt,
    this.onPutAll,
    this.onValuesBetween,
    this.onWatch,
  }) : _store = Map<dynamic, T>.from(initialValues ?? const {}),
       _isOpen = true,
       _nextIntKey = 0 {
    _nextIntKey = _calculateNextIntKey();
  }

  final Map<dynamic, T> _store;
  final StreamController<BoxEvent> _events = StreamController<BoxEvent>.broadcast();

  int _nextIntKey;
  bool _isOpen;

  final ValueSetter<T>? onAdd;
  final ValueSetter<Iterable<T>>? onAddAll;
  final VoidCallback? onClear;
  final VoidCallback? onClose;
  final VoidCallback? onCompact;
  final ValueSetter<dynamic>? onContainsKey;
  final ValueSetter<dynamic>? onDelete;
  final ValueSetter<int>? onDeleteAt;
  final ValueSetter<Iterable<dynamic>>? onDeleteAll;
  final VoidCallback? onDeleteFromDisk;
  final VoidCallback? onFlush;
  final ValueSetter<dynamic>? onGet;
  final ValueSetter<int>? onGetAt;
  final ValueSetter<int>? onKeyAt;
  final void Function(Object? key, T value)? onPut;
  final void Function(int index, T value)? onPutAt;
  final void Function(Map<dynamic, T> entries)? onPutAll;
  final void Function(Object? startKey, Object? endKey)? onValuesBetween;
  final ValueSetter<dynamic>? onWatch;

  @override
  final String name;

  @override
  final String? path;

  @override
  final bool lazy;

  @override
  Future<int> add(T value) async {
    onAdd?.call(value);
    final key = _nextIntKey++;
    _store[key] = value;
    _emitEvent(BoxEvent(key, value, false));
    return key;
  }

  @override
  Future<Iterable<int>> addAll(Iterable<T> values) async {
    onAddAll?.call(values);
    final addedKeys = <int>[];
    for (final value in values) {
      final key = _nextIntKey++;
      _store[key] = value;
      addedKeys.add(key);
      _emitEvent(BoxEvent(key, value, false));
    }
    return addedKeys;
  }

  @override
  Future<int> clear() async {
    onClear?.call();
    final removedCount = _store.length;
    final removedKeys = List<dynamic>.from(_store.keys);
    _store.clear();
    _nextIntKey = 0;
    for (final key in removedKeys) {
      _emitEvent(BoxEvent(key, null, true));
    }
    return removedCount;
  }

  @override
  Future<void> close() async {
    onClose?.call();
    _isOpen = false;
    await _events.close();
  }

  @override
  Future<void> compact() async {
    onCompact?.call();
  }

  @override
  bool containsKey(Object? key) {
    onContainsKey?.call(key);
    return _store.containsKey(key);
  }

  @override
  Future<void> delete(Object? key) async {
    onDelete?.call(key);
    if (_store.containsKey(key)) {
      _store.remove(key);
      _emitEvent(BoxEvent(key, null, true));
    }
  }

  @override
  Future<void> deleteAll(Iterable keys) async {
    onDeleteAll?.call(keys);
    for (final key in keys) {
      if (_store.containsKey(key)) {
        _store.remove(key);
        _emitEvent(BoxEvent(key, null, true));
      }
    }
  }

  @override
  Future<void> deleteAt(int index) async {
    onDeleteAt?.call(index);
    if (index < 0 || index >= _store.length) {
      return;
    }
    final key = _store.keys.elementAt(index);
    _store.remove(key);
    _emitEvent(BoxEvent(key, null, true));
  }

  @override
  Future<void> deleteFromDisk() async {
    onDeleteFromDisk?.call();
    await clear();
    _isOpen = false;
    if (!_events.isClosed) {
      await _events.close();
    }
  }

  @override
  Future<void> flush() async {
    onFlush?.call();
  }

  @override
  T? get(Object? key, {T? defaultValue}) {
    onGet?.call(key);
    return _store[key] ?? defaultValue;
  }

  @override
  T? getAt(int index) {
    onGetAt?.call(index);
    if (index < 0 || index >= _store.length) {
      return null;
    }
    return _store.values.elementAt(index);
  }

  @override
  bool get isEmpty => _store.isEmpty;

  @override
  bool get isNotEmpty => _store.isNotEmpty;

  @override
  bool get isOpen => _isOpen;

  @override
  dynamic keyAt(int index) {
    onKeyAt?.call(index);
    return _store.keys.elementAt(index);
  }

  @override
  Iterable get keys => _store.keys;

  @override
  int get length => _store.length;

  @override
  Future<void> put(Object? key, T value) async {
    onPut?.call(key, value);
    _store[key] = value;
    _emitEvent(BoxEvent(key, value, false));
  }

  @override
  Future<void> putAll(Map<dynamic, T> entries) async {
    onPutAll?.call(entries);
    entries.forEach((key, value) {
      _store[key] = value;
      _emitEvent(BoxEvent(key, value, false));
    });
  }

  @override
  Future<void> putAt(int index, T value) async {
    onPutAt?.call(index, value);
    if (index < 0 || index >= _store.length) {
      throw RangeError.index(index, _store.values, 'index');
    }
    final key = _store.keys.elementAt(index);
    _store[key] = value;
    _emitEvent(BoxEvent(key, value, false));
  }

  @override
  Map<dynamic, T> toMap() {
    return Map<dynamic, T>.from(_store);
  }

  @override
  Iterable<T> get values => _store.values;

  @override
  Iterable<T> valuesBetween({Object? startKey, Object? endKey}) {
    onValuesBetween?.call(startKey, endKey);
    final keyList = _store.keys.toList();
    if (startKey != null) {
      final startIndex = keyList.indexOf(startKey);
      if (startIndex == -1) {
        return <T>[];
      }
      var endIndex = keyList.length - 1;
      if (endKey != null) {
        final endIndexCandidate = keyList.indexOf(endKey);
        if (endIndexCandidate != -1) {
          endIndex = endIndexCandidate;
        }
      }
      if (endIndex < startIndex) {
        return <T>[];
      }
      return _store.values.toList().sublist(startIndex, endIndex + 1);
    }
    if (endKey != null) {
      final endIndex = keyList.indexOf(endKey);
      if (endIndex == -1) {
        return _store.values;
      }
      return _store.values.toList().sublist(0, endIndex + 1);
    }
    return _store.values;
  }

  @override
  Stream<BoxEvent> watch({Object? key}) {
    onWatch?.call(key);
    if (key == null) {
      return _events.stream;
    }
    return _events.stream.where((event) => event.key == key);
  }

  int _calculateNextIntKey() {
    var nextKey = 0;
    for (final key in _store.keys.whereType<int>()) {
      if (key >= nextKey) {
        nextKey = key + 1;
      }
    }
    return nextKey;
  }

  void _emitEvent(BoxEvent event) {
    if (!_events.isClosed) {
      _events.add(event);
    }
  }
}
