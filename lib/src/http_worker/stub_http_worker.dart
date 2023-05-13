import 'dart:async';

import 'package:http_worker/http_worker.dart';

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
