import 'dart:async';

/// This class contains the response details of a request
/// This includes the [status] of the response
/// The [data] or the parsed body of the response
/// The [error] if the request failed or the parsing failed
/// and [hasError] which is true if the [error] is not null
/// and [isCancelled] which is true if the request was cancelled by the user.
/// If the request gets cancelled by the user, the [data] and [error] will
/// be null, and the [status] will be `-1`.
class Response<D> {
  Response(
      {required this.status, this.data, this.error, this.isCancelled = false})
      : hasError = error != null;

  final int status;
  final D? data;
  final bool hasError;
  final Object? error;
  final bool isCancelled;
}

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
