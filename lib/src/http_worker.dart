import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:unwired/src/parser.dart';
import 'package:unwired/src/request_handler.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:unwired/src/store_manager.dart';

import 'constants.dart';


/// [HttpWorker] is the base class for all the workers that process the requests.
/// This can be extended to create your own implementation for processing
/// requests.
///
/// For example, you can create a [HttpWorker] that processes requests on a pool
/// of [Isolates](https://www.youtube.com/watch?v=vl_AaCgudcY) with an
/// implementation of load balancer to balance the request across
/// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s.
abstract class HttpWorker {
  /// This method is called before any requests are processed. This can be used
  /// to complete any initialisation needed before the worker can call
  /// [processRequest].
  ///
  /// For example, if you are using
  /// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s to call requests,
  /// spawn the isolates in this function.
  Future init();

  /// Function to process the request. This function should return a [Completer]
  /// with [Response] as the future.
  Completer<Response<T>> processRequest<T>(
      int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser);

  /// Function to cancel the request with the given [id].
  Future killRequest(Object id);

  /// Function to destroy the worker. Currently, this is not used in this library.
  /// But, you can call this function from your application if you have access
  /// to the [HttpWorker] object to destroy it.
  ///
  /// This is where you can destroy the [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s
  /// if you are using them in your implementation.
  destroy();
}

/// [DebugHttpWorker] is an implementation of [HttpWorker] that processes
/// requests and prints the debug logs to the console. By default, this is only
/// used in debug mode.
class DebugHttpWorker extends HttpWorker {
  final RequestInfoStoreManager _storeManager = RequestInfoStoreManager();

  @override
  Future init() async {
    print("Started Unwired ⚡ Debug HTTP Worker");
  }

  @override
  Completer<Response<T>> processRequest<T>(
      int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser) {
    Completer<Response<T>> completer = Completer<Response<T>>();

    _storeManager.storeRequestInfo(
        requestId: id,
        completer: completer,
        url: url,
        method: method,
        header: header,
        body: body
    );

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
              print("GET Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
              print("POST Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
              print("PUT Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
              print("DELETE Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
              print("PATCH Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
              print("HEAD Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeFromStore(id);
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
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

/// An [HttpWorker] implementation for web platform. This is perhaps the
/// simplest implementation of [HttpWorker]. You can override the default
/// setting in [RequestHandler] to use this for both web and native platforms
/// for its simplicity.
class WebHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  Completer<Response<T>> processRequest<T>(
      int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser) {
    Completer<Response<T>> completer =
        Completer<Response<T>>();

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
    }
    return completer;
  }

  @override
  Future killRequest(Object id) async {}

  @override
  destroy() {}
}

/// This implementation of [HttpWorker] is used to handle http requests in a
/// separate [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY). By default,
/// it is used by native devices as the web platform does not support
/// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s.
class NativeHttpWorker extends HttpWorker {
  final RequestCompleterStoreManager _storeManager = RequestCompleterStoreManager();
  final ReceivePort _receivePort = ReceivePort();
  late final Isolate _isolate;
  late final SendPort _sendPort;

  @override
  Future init() async {
    _isolate = await Isolate.spawn<SendPort>((sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      receivePort.listen((message) {
        final data = (message as Map<String, Object?>);

        final Object id = data[ID]!;
        final RequestMethod method = data[METHOD]! as RequestMethod;
        final Uri url = data[URL]! as Uri;
        final Map<String, String>? header = data[HEADER] as Map<String, String>?;
        final body = data[BODY];
        final Parser? parser = data[PARSER] as Parser?;

        switch (method) {
          case RequestMethod.get:
            http.get(url, headers: header).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(
                      status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE:
                  Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send({
                  ID: id,
                  RESPONSE: (Response(status: -1, error: e))
                }));
            break;
          case RequestMethod.post:
            http.post(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(
                      status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE:
                  Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send({
                  ID: id,
                  RESPONSE: (Response(status: -1, error: e))
                }));
            break;
          case RequestMethod.put:
            http.put(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(
                      status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE:
                  Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send({
                  ID: id,
                  RESPONSE: (Response(status: -1, error: e))
                }));
            break;
          case RequestMethod.delete:
            http.delete(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(
                      status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE:
                  Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send({
                  ID: id,
                  RESPONSE: (Response(status: -1, error: e))
                }));
            break;
          case RequestMethod.patch:
            http.patch(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(
                      status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE:
                  Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send({
                  ID: id,
                  RESPONSE: (Response(status: -1, error: e))
                }));
            break;
          case RequestMethod.head:
            http.head(url, headers: header).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(
                      status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE:
                  Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send({
                  ID: id,
                  RESPONSE: (Response(status: -1, error: e))
                }));
            break;
        }
      });
    }, _receivePort.sendPort);

    _sendPort = await _receivePort.first;

    _receivePort.listen((data) {
      final dataMap = data as Map<String, Object?>;
      final Object id = dataMap[ID]!;
      final completer = _storeManager.getRequestCompleter(id);
      if (!(completer?.isCompleted ?? true))
        completer?.complete(dataMap[RESPONSE]);
      _storeManager.removeFromStore(id);
    });
  }

  @override
  Completer<Response<T>> processRequest<T>(
      int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser) {
    Completer<Response<T>> completer =
    Completer<Response<T>>();

    _storeManager.storeCompleter(requestId: id, completer: completer);

    _sendPort.send({
      ID: id,
      URL: url,
      METHOD: method,
      HEADER: header,
      BODY: body,
      PARSER: parser
    });

    return completer;
  }

  @override
  Future killRequest(Object id) async {
    _storeManager.removeFromStore(id);
  }

  @override
  destroy() {
    _isolate.kill();
  }
}
