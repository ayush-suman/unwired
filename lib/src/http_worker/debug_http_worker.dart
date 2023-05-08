import 'dart:async';
import 'dart:convert';

import 'package:unwired/src/http_worker/http_worker.dart';
import 'package:unwired/src/parser.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart';
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
  Completer<Response<T>> processRequest<T>(Object id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser) {
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
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
              print("GET Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
              print("POST Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
              print("PUT Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
              print("DELETE Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
              print("PATCH Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response(status: -1, error: e));
          }
        });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
              print("HEAD Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted) {
            completer.complete(Response(status: -1, error: e));
          }
        });
        break;
    }
    return completer;
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
