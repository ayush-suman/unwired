import 'dart:async';

import 'package:http_worker/http_worker.dart';

class DefaultHttpWorker extends HttpWorker {
  DefaultHttpWorker({this.debug = true}): super();

  final bool debug;

  @override
  Future init() {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  (Completer<Response<T>>, {Object? meta}) processRequest<T>(
      {required int id,
        required RequestMethod method,
        required Uri url,
        Map<String, String>? header,
        Object? body,
        Parser<T>? parser,
        Map<String, Object?>? meta
      }) {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  Future killRequest(int id) {
    throw UnimplementedError('Unidentified platform');
  }

  @override
  destroy() {
    throw UnimplementedError('Unidentified platform');
  }
}
