import 'dart:async';

import 'package:unwired/src/parser.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart';

export 'package:unwired/src/http_worker/debug_http_worker.dart';
export 'package:unwired/src/http_worker/stub_http_worker.dart'
    if (dart.library.io) 'package:unwired/src/http_worker/native_http_worker.dart'
    if (dart.library.html) 'package:unwired/src/http_worker/web_http_worker.dart';

/// This is the base class for all the workers that process the requests.
/// This can be extended to create your own implementation for processing
/// requests.
///
/// For example, you can create a [HttpWorker] that processes requests on a pool
/// of [Isolates](https://www.youtube.com/watch?v=vl_AaCgudcY) with an
/// implementation of load balancer to balance the request across
/// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s.
abstract class HttpWorker {
  const HttpWorker();

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
  Completer<Response<T>> processRequest<T>(Object id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser);

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
