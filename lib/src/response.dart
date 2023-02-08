class Response<D> {
  Response({required this.status, this.data, this.error, this.isCancelled=false}): hasError = error!=null;

  final int status;
  final D? data;
  final bool hasError;
  final Object? error;
  final bool isCancelled;
}

class Cancellable<T> {
  Cancellable(this.response, {this.onCancel});

  Future<Response<T>> response;
  Function()? onCancel;

  bool _cancelled = false;

  bool get cancelled => _cancelled;

  cancel() {
    _cancelled = true;
    onCancel?.call();
  }
}

class StatusCode {
  static const int Cancelled = -1;
  static const int OK = 200;
  static const int NotFound = 404;
}