import 'dart:async';

import 'package:http_worker/http_worker.dart';

class DefaultHttpWorker extends HttpWorker {
  @override
  Future init() {
    throw UnimplementedError('Unidentified platform');
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
