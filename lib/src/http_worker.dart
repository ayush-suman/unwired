import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:unwired/src/parser.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart' as response;
import 'package:http/http.dart' as http;
import 'package:unwired/src/store_manager.dart';

abstract class HttpWorker {
  Future init();

  Completer<response.Response<T>> processRequest<T>(int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser);

  Future killRequest(int id);

  destroy();
}

class NativeHttpWorker extends HttpWorker {
  final RequestInfoStoreManager _storeManager = RequestInfoStoreManager();
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

        final id = data["ID"] as int;
        final method = data["METHOD"] as RequestMethod;
        final url = data["URL"] as Uri;
        final header = data["HEADER"] as Map<String, String>?;
        final body = data["BODY"];
        final parser = data["PARSER"] as Parser?;

        switch (method) {
          case RequestMethod.get:
            http.get(url, headers: header).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, data: data ?? json)});
              } catch (e) {
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, error: e)});
              }
            },
                onError: (e) =>
                    sendPort.send({"ID": id, "RESPONSE": (response.Response(status: -1, error: e))}));
            break;
          case RequestMethod.post:
            http.post(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, data: data ?? json)});
              } catch (e) {
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, error: e)});
              }
            },
                onError: (e) =>
                sendPort.send({"ID": id, "RESPONSE": (response.Response(status: -1, error: e))}));
            break;
          case RequestMethod.put:
            http.put(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, data: data ?? json)});
              } catch (e) {
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, error: e)});
              }
            },
                onError: (e) =>
                    sendPort.send({"ID": id, "RESPONSE": (response.Response(status: -1, error: e))}));
            break;
          case RequestMethod.delete:
            http.delete(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, data: data ?? json)});
              } catch (e) {
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, error: e)});
              }
            },
                onError: (e) =>
                    sendPort.send({"ID": id, "RESPONSE": (response.Response(status: -1, error: e))}));
            break;
          case RequestMethod.patch:
            http.patch(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, data: data ?? json)});
              } catch (e) {
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, error: e)});
              }
            },
                onError: (e) =>
                    sendPort.send({"ID": id, "RESPONSE": (response.Response(status: -1, error: e))}));
            break;
          case RequestMethod.head:
            http.head(url, headers: header).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, data: data ?? json)});
              } catch (e) {
                sendPort.send({"ID": id, "RESPONSE": response.Response(status: value.statusCode, error: e)});
              }
            },
                onError: (e) =>
                    sendPort.send({"ID": id, "RESPONSE": (response.Response(status: -1, error: e))}));
            break;
        }
      });
    }, _receivePort.sendPort);

    _sendPort = await _receivePort.first;

    _receivePort.listen((data) {
      final dataMap = data as Map<String, Object?>;
      final id = dataMap["ID"]! as int;
      final completer = _storeManager.getRequestCompleter(id);
      if (!(completer?.isCompleted??true)) completer?.complete(dataMap["RESPONSE"]);
      _storeManager.removeRequestInfoFromStore(id);
  });
  }

  @override
  Completer<response.Response<T>> processRequest<T>(int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser) {
    Completer<response.Response<T>> completer = Completer<response.Response<T>>();

    _storeManager.addToStore({id: {
      RequestInfoStoreManager.completer: completer
    }});

    _sendPort.send({
      "ID": id,
      "URL": url,
      "METHOD": method,
      "HEADER": header,
      "BODY": body,
      "PARSER": parser
    });

    return completer;
  }

  @override
  Future killRequest(int id) async {
    _storeManager.removeRequestInfoFromStore(id);
  }

  @override
  destroy() {
    _isolate.kill();
  }
}

class WebHttpWorker extends HttpWorker {

  @override
  Future init() async {}

  @override
  Completer<response.Response<T>> processRequest<T>(int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser) {
    Completer<response.Response<T>> completer =
    Completer<response.Response<T>>();

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
    }
    return completer;
  }

  @override
  Future killRequest(int id) async {}

  @override
  destroy() {}
}

class DebugHttpWorker extends HttpWorker {
  final RequestInfoStoreManager _storeManager = RequestInfoStoreManager();

  @override
  Future init() async {
    print("Started Unwired ⚡ Debug HTTP Worker");
  }

  @override
  Completer<response.Response<T>> processRequest<T>(int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser) {
    Completer<response.Response<T>> completer =
    Completer<response.Response<T>>();

    _storeManager.addToStore({id: {
      RequestInfoStoreManager.completer: completer,
      RequestInfoStoreManager.url: url,
      RequestInfoStoreManager.method: method,
      RequestInfoStoreManager.header: header,
      RequestInfoStoreManager.body: body
    }
    });

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
              print("GET Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeRequestInfoFromStore(id);
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
              print("POST Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeRequestInfoFromStore(id);
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
              print("PUT Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeRequestInfoFromStore(id);
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
              print("DELETE Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeRequestInfoFromStore(id);
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
              print("PATCH Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeRequestInfoFromStore(id);
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(response.Response(
                  status: value.statusCode, data: data ?? json));
              print("HEAD Request to $url completed");
            } catch (e) {
              if (!completer.isCompleted) {
                completer.complete(
                    response.Response(status: value.statusCode, error: e));
              }
            } finally {
              _storeManager.removeRequestInfoFromStore(id);
            }
          }
        },
            onError: (e) {
              if (!completer.isCompleted) completer.complete(response.Response(status: -1, error: e));
            });
        break;
    }
    return completer;
  }

  @override
  Future killRequest(int id) async {
    Map<String, Object?>? debugInfo = _storeManager.getDebugInfoOfRequest(id);
    if (debugInfo != null) {
      print("${debugInfo[RequestInfoStoreManager
          .method]} Request to ${debugInfo[RequestInfoStoreManager
          .url]} cancelled by user");
      _storeManager.removeRequestInfoFromStore(id);
    }
  }

  @override
  destroy() {
    print("Stopped Unwired ⚡ Debug HTTP Worker");
  }
}

