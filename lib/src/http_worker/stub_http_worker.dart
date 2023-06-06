import 'dart:async';

import 'package:http_worker/http_worker.dart';

class DefaultHttpWorker<K> extends HttpWorker<K> {
  @override
  Future init() {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  (Completer<Response<T>>, {Object? meta}) processRequest<T>(
      {required K id,
        required RequestMethod method,
        required Uri url,
        Map<String, String>? header,
        Object? body,
        Parser<T>? parser,
        Map<String, Object?> meta = const {}
      }) {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  Future killRequest(K id) {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  destroy() {
    throw UnimplementedError('Unidentified platform');
  }
}
