import 'dart:async';

abstract class StoreManager<K, V> {
  final Map<K, V> _store = Map<K, V>();

  void addToStore(Map<K, V> element){
    return _store.addAll(element);
  }

  bool storeContains(K key) {
    return _store.containsKey(key);
  }

  bool removeFromStore(K key) {
    return _store.remove(key) != null;
  }

  void removeFromStoreIf(bool Function(K, V) filter) {
    _store.removeWhere(filter);
  }

  Map<K, V> createNewStoreObject();
}

class RequestInfoStoreManager extends StoreManager<int, Map<String, Object?>> {
  static const String id = 'id';
  static const String completer = "COMPLETER";
  static const String url = "URL";
  static const String method = "REQUEST_METHOD";
  static const String header = "HEADER";
  static const String body = "BODY";
  static const String parser = "PARSER";

  Map<String, Object?>? getDebugInfoOfRequest(int requestId) {
    return _store[requestId];
  }

  Completer<T>? getRequestCompleter<T>(int requestId) {
    return getDebugInfoOfRequest(requestId)?[completer] as Completer<T>?;
  }

  removeRequestInfoFromStore(int requestId) {
    this.removeFromStore(requestId);
  }

  @override
  Map<int, Map<String, Object>> createNewStoreObject() {
    throw UnsupportedError('Cant create new store objects');
  }
}