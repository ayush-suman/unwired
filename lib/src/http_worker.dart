import 'dart:async';

import 'package:unwired/src/queue_manager.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart' as response;
import 'package:http/http.dart' as http;

abstract class HttpWorker {
  Future init();

  Completer<response.Response> processRequest(int id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body);

  Future killRequest(int id);

  destroy();
}

class NativeHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  Completer<response.Response> processRequest(int id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body) {
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
  Completer<response.Response> processRequest(int id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body) {
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
  Completer<response.Response> processRequest(
      int id,
      RequestMethod method,
      Uri url,
      Map<String, String>? header,
      Object? body) {

    Completer<response.Response> completer = Completer<response.Response>();
    queueManager.addToQueue({id: completer});

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          // TODO: Parse response body
          completer.complete(
              response.Response(status: value.statusCode, data: value.body));
          queueManager.removeFromQueueIf((p0) => p0[id]!=null);
        });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          // TODO: Parse response body
          completer.complete(
              response.Response(status: value.statusCode, data: value.body));
          queueManager.removeFromQueueIf((p0) => p0[id]!=null);
        });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          // TODO: Parse response body
          if (queueManager.queueContains((p0) => p0[id]!=null)) {
            completer.complete(
                response.Response(status: value.statusCode, data: value.body));
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          // TODO: Parse response body
          if (queueManager.queueContains((p0) => p0[id]!=null)) {
            completer.complete(
                response.Response(status: value.statusCode, data: value.body));
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          // TODO: Parse response body
          if (queueManager.queueContains((p0) => p0[id]!=null)) {
            completer.complete(
                response.Response(status: value.statusCode, data: value.body));
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          // TODO: Parse response body
          if (queueManager.queueContains((p0) => p0[id]!=null)) {
            completer.complete(
                response.Response(status: value.statusCode, data: value.body));
            queueManager.removeFromQueueIf((p0) => p0[id] != null);
          }
        });
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
