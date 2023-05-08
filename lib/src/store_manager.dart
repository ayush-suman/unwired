import 'dart:async';

import 'package:unwired/src/constants.dart';
import 'package:unwired/src/request_method.dart';

/// Stores objects of type [V] with keys of type [K]
/// This is useful for storing values that can be fetched
/// their known meta data such as an id, name etc.
///
/// Extend this class to create your own [StoreManager]
abstract class StoreManager<K, V> {
  StoreManager();

  final Map<K, V> _store = Map<K, V>();

  /// Adds an element to the store
  void addToStore(Map<K, V> element) {
    return _store.addAll(element);
  }

  /// Returns the element with the given key
  bool storeContains(K key) {
    return _store.containsKey(key);
  }

  /// Removes the element with the given key
  bool removeFromStore(K key) {
    return _store.remove(key) != null;
  }

  /// Removes all elements that satisfy the given [filter]
  void removeFromStoreIf(bool Function(K, V) filter) {
    _store.removeWhere(filter);
  }

  Map<K, V> createNewStoreObject();
}

/// A [StoreManager] to store request [Completer]s with the request id
/// as the key and [Completer] of the request as the value.
class RequestCompleterStoreManager extends StoreManager<Object, Completer> {
  /// Stores the request information in the store
  void storeCompleter<T>(
      {required Object requestId, required Completer<T> completer}) {
    addToStore({requestId: completer});
  }

  /// Returns the [Completer] of the request with [requestId]
  Completer<T>? getRequestCompleter<T>(Object requestId) {
    return _store[requestId] as Completer<T>?;
  }

  @override
  Map<int, Completer> createNewStoreObject() {
    throw UnsupportedError('Cant create new store objects');
  }
}

/// A [StoreManager] to store request debug info with the request id
/// as the key and a [Map] of request information as the value.
class RequestInfoStoreManager
    extends StoreManager<Object, Map<String, Object?>> {
  /// Stores the request information in the store
  void storeRequestInfo<T>(
      {required Object requestId,
      required Completer<T> completer,
      required Uri url,
      required RequestMethod method,
      Map<String, String>? header,
      Object? body}) {
    addToStore({
      requestId: {
        COMPLETER: completer,
        URL: url,
        METHOD: method,
        HEADER: header,
        BODY: body
      }
    });
  }

  /// Returns the request information of the request with [requestId]
  Map<String, Object?>? getDebugInfoOfRequest(Object requestId) {
    return _store[requestId];
  }

  /// Returns the [Completer] of the request with [requestId]
  Completer<T>? getRequestCompleter<T>(Object requestId) {
    return getDebugInfoOfRequest(requestId)?[COMPLETER] as Completer<T>?;
  }

  @override
  Map<int, Map<String, Object>> createNewStoreObject() {
    throw UnsupportedError('Cant create new store objects');
  }
}
