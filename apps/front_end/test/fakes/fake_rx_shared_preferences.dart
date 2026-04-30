// ignore_for_file: join_return_with_assignment, close_sinks

import 'dart:async';

import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class FakeRxSharedPreferences implements RxSharedPreferences {
  factory FakeRxSharedPreferences({Map<String, Object?>? initialValues}) {
    final store = Map<String, Object?>.from(initialValues ?? const {});
    final controller = _createAllController(store);
    return FakeRxSharedPreferences._(store, controller);
  }

  FakeRxSharedPreferences._(this._store, this._allController);

  final Map<String, Object?> _store;
  final Map<String, StreamController<Object?>> _controllers = {};
  final StreamController<Map<String, Object?>> _allController;

  StreamController<Object?> _controllerForKey(String key) {
    return _controllers.putIfAbsent(
      key,
      () =>
          StreamController<Object?>.broadcast(onListen: () => _controllers[key]?.add(_store[key])),
    );
  }

  void _emitKey(String key) {
    final controller = _controllers[key];
    if (controller != null && !controller.isClosed) {
      controller.add(_store[key]);
    }
  }

  void _emitAll() {
    if (!_allController.isClosed) {
      _allController.add(Map<String, Object?>.from(_store));
    }
  }

  @override
  Future<bool> containsKey(String key, [void options]) async {
    return _store.containsKey(key);
  }

  @override
  Future<T?> read<T extends Object>(String key, Decoder<T?> decoder, [void options]) async {
    return decoder(_store[key]);
  }

  @override
  Future<Map<String, Object?>> readAll([void options]) async {
    return Map<String, Object?>.from(_store);
  }

  @override
  Future<void> clear([void options]) async {
    final keys = List<String>.from(_store.keys);
    _store.clear();
    keys.forEach(_emitKey);
    _emitAll();
  }

  @override
  Future<void> remove(String key, [void options]) async {
    _store.remove(key);
    _emitKey(key);
    _emitAll();
  }

  @override
  Future<void> write<T extends Object>(
    String key,
    T? value,
    Encoder<T?> encoder, [
    void options,
  ]) async {
    if (value == null) {
      _store.remove(key);
    } else {
      _store[key] = await encoder(value);
    }
    _emitKey(key);
    _emitAll();
  }

  @override
  Stream<T?> observe<T extends Object>(String key, Decoder<T?> decoder, [void options]) {
    return _controllerForKey(key).stream.asyncMap((event) async => decoder(event));
  }

  @override
  Stream<Map<String, Object?>> observeAll([void options]) {
    return _allController.stream;
  }

  @override
  Future<void> update<T extends Object>({
    required String key,
    required Decoder<T?> decoder,
    required Transformer<T?> transformer,
    required Encoder<T?> encoder,
    void options,
  }) async {
    final current = await read<T>(key, decoder);
    final transformed = await transformer(current);
    await write<T>(key, transformed, encoder);
  }

  @override
  Future<void> executeUpdate<T extends Object>(
    String key,
    Decoder<T?> decoder,
    Transformer<T?> transformer,
    Encoder<T?> encoder, [
    void options,
  ]) {
    return update<T>(key: key, decoder: decoder, transformer: transformer, encoder: encoder);
  }

  @override
  Future<void> dispose() async {
    for (final controller in _controllers.values) {
      await controller.close();
    }
    await _allController.close();
  }

  @override
  Future<Map<String, Object?>> reload() {
    return readAll();
  }

  static StreamController<Map<String, Object?>> _createAllController(Map<String, Object?> store) {
    late final StreamController<Map<String, Object?>> controller;
    controller = StreamController<Map<String, Object?>>.broadcast(
      onListen: () => controller.add(Map<String, Object?>.from(store)),
    );
    return controller;
  }
}
