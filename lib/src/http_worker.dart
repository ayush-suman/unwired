import 'dart:async';
import 'dart:convert';

import 'package:unwired/src/parser.dart';
import 'package:unwired/src/queue_manager.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart' as response;
import 'package:http/http.dart' as http;

abstract class HttpWorker {
  Future init();

  Completer<response.Response<T>> processRequest<T>(int id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser);

  Future killRequest(int id);

  destroy();
}

class NativeHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  Completer<response.Response<T>> processRequest<T>(int id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser) {
    // TODO: implement processRequest
    throw UnimplementedError();
  }

  @override
  Future killRequest(int id) async {}

  @override
  destroy() {}
}

class WebHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  Completer<response.Response<T>> processRequest<T>(int id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser) {
    // TODO: implement processRequest
    throw UnimplementedError();
  }

  @override
  Future killRequest(int id) async {}

  @override
  destroy() {}
}

class DebugHttpWorker extends HttpWorker {
  final CompleterQueueManager queueManager = CompleterQueueManager();

  @override
  Future init() async {
  }

  @override
  Completer<response.Response<T>> processRequest<T>(
      int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser) {

    Completer<response.Response<T>> completer = Completer<response.Response<T>>();
    queueManager.addToQueue({id: completer});

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          final json = jsonDecode(value.body);
          try {
            T? data = parser?.parse(json);
            completer.complete(
                response.Response(status: value.statusCode, data: data??json));
          } catch (e) {
            completer.complete(
              response.Response(status: value.statusCode, error: e));
          } finally {
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        }, onError: (e) => completer.complete(response.Response(status: -1, error: e)));
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          final json = jsonDecode(value.body);
          try {
            T? data = parser?.parse(json);
            completer.complete(
                response.Response(status: value.statusCode, data: data??json));
          } catch (e) {
            completer.complete(
                response.Response(status: value.statusCode, error: e));
          } finally {
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        }, onError: (e) => completer.complete(response.Response(status: -1, error: e)));
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          final json = jsonDecode(value.body);
          try {
            T? data = parser?.parse(json);
            completer.complete(
                response.Response(status: value.statusCode, data: data??json));
          } catch (e) {
            completer.complete(
                response.Response(status: value.statusCode, error: e));
          } finally {
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        }, onError: (e) => completer.complete(response.Response(status: -1, error: e)));
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          final json = jsonDecode(value.body);
          try {
            T? data = parser?.parse(json);
            completer.complete(
                response.Response(status: value.statusCode, data: data??json));
          } catch (e) {
            completer.complete(
                response.Response(status: value.statusCode, error: e));
          } finally {
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        }, onError: (e) => completer.complete(response.Response(status: -1, error: e)));
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          final json = jsonDecode(value.body);
          try {
            T? data = parser?.parse(json);
            completer.complete(
                response.Response(status: value.statusCode, data: data??json));
          } catch (e) {
            completer.complete(
                response.Response(status: value.statusCode, error: e));
          } finally {
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        }, onError: (e) => completer.complete(response.Response(status: -1, error: e)));
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          final json = jsonDecode(value.body);
          try {
            T? data = parser?.parse(json);
            completer.complete(
                response.Response(status: value.statusCode, data: data??json));
          } catch (e) {
            completer.complete(
                response.Response(status: value.statusCode, error: e));
          } finally {
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        }, onError: (e) => completer.complete(response.Response(status: -1, error: e)));
        break;
    }
    return completer;
  }

  @override
  Future killRequest(int id) async {
    queueManager.removeFromQueueIf((p0) => p0[id]!=null);
  }

  @override
  destroy() {}
}
