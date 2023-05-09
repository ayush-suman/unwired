import 'dart:async';

import 'package:unwired/src/response.dart';

extension CompleteWithResponse<T> on Completer<Response<T>> {
  void completeWith({required int statusCode, T? data, Object? error}) {
    complete(Response<T>(status: statusCode, data: data, error: error));
  }
}
