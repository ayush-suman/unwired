class Response<D> {
  Response({this.data, this.error, this.isCancelled=false}): hasError = error!=null;

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