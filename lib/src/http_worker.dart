import 'dart:async';

import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart' as response;

abstract class HttpWorker {
  Future init();

  Completer<response.Response> processRequest(int id, RequestMethod method, Uri url, Map<String, dynamic>? header, Object? body);

  Future killRequest(int id);

  destroy();
}

class NativeHttpWorker extends HttpWorker {
  @override
  Future init() async {

  }

  @override
  Completer<response.Response> processRequest(int id, RequestMethod method, Uri url, Map<String, dynamic>? header, Object? body) {
    // TODO: implement processRequest
    throw UnimplementedError();
  }

  @override
  Future killRequest(int id) async {

  }

  @override
  destroy() {

  }
}

class WebHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  Completer<response.Response> processRequest(int id, RequestMethod method, Uri url, Map<String, dynamic>? header, Object? body) {
    // TODO: implement processRequest
    throw UnimplementedError();
  }

  @override
  Future killRequest(int id) async {

  }

  @override
  destroy() {}
}

class DebugHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  Completer<response.Response> processRequest(int id, RequestMethod method, Uri url, Map<String, dynamic>? header, Object? body) {
    // TODO: implement processRequest
    throw UnimplementedError();
  }

  @override
  Future killRequest(int id) async {

  }

  @override
  destroy() {}
}
