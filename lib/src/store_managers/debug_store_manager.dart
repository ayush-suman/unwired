import 'dart:async';

import 'package:http_worker/http_worker.dart';
import 'package:store_manager/store_manager.dart';
import 'package:unwired/src/constants.dart';

/// A [StoreManager] to store request debug info with the request id
/// as the key and a [Map] of request information as the value.
class RequestInfoStoreManager<K>
    extends StoreManager<K, Map<String, Object?>> {
  /// Stores the request information in the store
  void storeRequestInfo<T>(
      {required K requestId,
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
  Map<String, Object?>? getDebugInfoOfRequest(K requestId) {
    return getFromStore(requestId);
  }

  /// Returns the [Completer] of the request with [requestId]
  Completer<T>? getRequestCompleter<T>(K requestId) {
    return getDebugInfoOfRequest(requestId)?[COMPLETER] as Completer<T>?;
  }

  @override
  Map<K, Map<String, Object>> createNewStoreObject() {
    throw UnsupportedError('Cant create new request info objects using this function');
  }
}
