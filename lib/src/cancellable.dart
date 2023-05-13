import 'dart:async';

import 'package:http_worker/http_worker.dart';

/// This contains the [Response] of a request and a [cancel] method
/// On making a request, it returns the [Cancellable] object immediately
/// without waiting for the request to complete.
/// The user can cancel the request by calling the [cancel] method
/// before the response arrives. It is safe to call the [cancel] method,
/// even after the response arrives. In that case, the [cancel] method will
/// do nothing.
class Cancellable<T> {
  Cancellable(this._completer, {this.onCancel});

  final Completer<Response<T>> _completer;
  Future<Response<T>> get response => _completer.future;
  Function()? onCancel;

  bool _cancelled = false;

  bool get cancelled => _cancelled;

  cancel() {
    if (!_completer.isCompleted) {
      _completer.complete(Response(status: -1, isCancelled: true));
      _cancelled = true;
      onCancel?.call();
    }
  }
}
