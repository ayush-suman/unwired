import 'dart:async';

import 'package:http_worker/http_worker.dart';
import 'package:unwired/src/store_manager.dart';
import 'package:unwired/src/constants.dart';
import 'package:http/http.dart' as http;

/// This is an implementation of [HttpWorker] that processes
/// requests and prints the debug logs to the console. By default, this is only
/// used in debug mode.
class DebugHttpWorker extends HttpWorker {
  final RequestInfoStoreManager _storeManager = RequestInfoStoreManager();

  @override
  Future init() async {
    print("Started Unwired ⚡ Debug HTTP Worker");
  }

  @override
  (Completer<Response<T>>, {Object? meta}) processRequest<T>(
      {required Object id,
        required RequestMethod method,
        required Uri url,
        Map<String, String>? header,
        Object? body,
        Parser<T>? parser,
        Object? meta
      }) {
    Completer<Response<T>> completer = Completer<Response<T>>();

    _storeManager.storeRequestInfo(
        requestId: id,
        completer: completer,
        url: url,
        method: method,
        header: header,
        body: body);

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
              print("GET Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response<T>(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
              print("POST Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response<T>(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
              print("PUT Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response<T>(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
              print("DELETE Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response<T>(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
              print("PATCH Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response<T>(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
              print("HEAD Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response<T>(status: -1, error: e));
          }
        });
        break;
    }
    return (completer, meta: null);
  }

  @override
  Future killRequest(Object id) async {
    Map<String, Object?>? debugInfo = _storeManager.getDebugInfoOfRequest(id);
    if (debugInfo != null) {
      print(
          "${debugInfo[METHOD]} Request to ${debugInfo[URL]} cancelled by user");
      _storeManager.removeFromStore(id);
    }
  }

  @override
  destroy() {
    print("Stopped Unwired ⚡ Debug HTTP Worker");
  }
}
