import 'dart:async';

import 'package:unwired/src/http_worker/http_worker.dart';
import 'package:unwired/src/parser.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart';

class DefaultHttpWorker extends HttpWorker {
  @override
  Future init() {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  Completer<Response<T>> processRequest<T>(Object id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser) {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  destroy() {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  Future killRequest(Object id) {
    throw UnimplementedError('Unidentified platform');
  }
}
