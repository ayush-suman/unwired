import 'dart:async';

import 'package:queue_manager/queue_manager.dart';
import 'package:unwired/src/auth_manager/auth_manager.dart';
import 'package:unwired/src/http_worker/http_worker.dart';
import 'package:unwired/src/parser.dart';
import 'package:unwired/src/queue_manager.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart';

/// This is used to create HTTP requests.
class RequestHandler {
  RequestHandler(
      {

      /// [AuthManager] is used to store token or manage the state of authentication
      /// for an application.
      ///
      /// One can create their own [AuthManager] to create
      /// their own implementation of managing the authentication or to not manage
      /// authentication at all.
      ///
      /// This value can be set to null only if you never use auth parameter in
      /// the [request] method.
      AuthManager? authManager,

      /// [HttpWorker] does the job of processing requests.
      /// It can be used to process requests on separate
      /// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)
      /// or a pool of Isolates or for debugging and testing
      ///
      /// Currently, there are two implementations of [HttpWorker] available:
      /// [DebugHttpWorker] and [DefaultHttpWorker]. It is recommended to use
      /// [DefaultHttpWorker] in release mode.
      HttpWorker? worker,

      /// [QueueManager] contains the strategy used to store the ongoing requests'
      /// meta data. This can be used to limit the maximum number of ongoing
      /// requests or to implement your own logic for managing the queue.
      ///
      /// [RequestIdQueueManager] is the default value of the [requestQueueManager].
      QueueManager? requestQueueManager}) {
    _authManager = authManager;
    _worker = worker ?? DebugHttpWorker();
    _requestQueueManager = requestQueueManager ?? RequestIdQueueManager();
  }

  /// This function should be called before making any requests.
  /// It initialises the [AuthManager] and [HttpWorker].
  ///
  /// [HttpWorker] is needed to process the requests. [AuthManager] is needed
  /// to manage the authentication state and credentials of the application.
  ///
  /// In general, the best place to call this function would be before
  /// The `runApp` method in the `main` function.
  Future initialise() async {
    return Future.wait([
      if (_authManager != null) _authManager!.synchronize(),
      _worker.init()
    ]);
  }

  /// [QueueManager] contains the strategy used to store the ongoing requests'
  /// meta data. This can be used to limit the maximum number of ongoing
  /// requests or to implement your own logic for managing the queue
  late final QueueManager _requestQueueManager;

  /// [HttpWorker] does the job of processing requests.
  /// It can be used to process requests on separate
  /// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)
  /// or a pool of Isolates or for debugging and testing
  ///
  /// Currently, there are two implementations of [HttpWorker] available:
  /// [DebugHttpWorker] and [DefaultHttpWorker]. It is recommended to use
  /// [DefaultHttpWorker] in release mode.
  late final HttpWorker _worker;

  /// [AuthManager] is used to store token or manage the state of authentication
  /// for an application.
  ///
  /// One can create their own [AuthManager] to create
  /// their own implementation of managing the authentication or to not manage
  /// authentication at all
  late final AuthManager? _authManager;

  /// Function to make a network request and returns a [Cancellable]. The
  /// [Cancellable] contains the [Future] of the [Response] of the request, and
  /// a [Cancellable.cancel] method to cancel the ongoing request before it completes.
  Cancellable<T> request<T>(
      {RequestMethod method = RequestMethod.get,
      required String url,
      Map<String, String>? params,
      Map<String, String>? header,
      Object? body,
      bool auth = false,
      Parser<T>? parser}) {
    int id = _requestQueueManager.createNewQueueObject();

    // Add params to url for parsing into Uri
    if (url.contains('?')) {
      url = params != null
          ? '$url&${params.entries.map((e) => "${e.key}=${e.value}").join('&')}'
          : url;
    } else {
      url = params != null
          ? '$url?${params.entries.map((e) => "${e.key}=${e.value}").join('&')}'
          : url;
    }
    Uri uri = Uri.parse(url);

    // Add auth token if auth is true
    if (auth && _authManager != null)
      header == null
          ? header = {'Authorization': _authManager!.parsedAuthObject}
          : header.addAll({'Authorization': _authManager!.parsedAuthObject});

    Completer<Response<T>> completer =
        _worker.processRequest<T>(id, method, uri, header, body, parser);

    return Cancellable(completer, onCancel: () {
      _killRequest(id);
    });
  }

  /// Function to make a GET network request
  Cancellable<T> get<T>(
      {required String url,
      Map<String, String>? params,
      Map<String, String>? header,
      bool auth = false,
      Parser<T>? parser}) {
    return request(
        method: RequestMethod.get,
        url: url,
        params: params,
        auth: auth,
        parser: parser);
  }

  /// Function to make a POST network request
  Cancellable<T> post<T>(
      {required String url,
      Map<String, String>? params,
      Map<String, String>? header,
      Object? body,
      bool auth = false,
      Parser<T>? parser}) {
    return request(
        method: RequestMethod.post,
        url: url,
        params: params,
        body: body,
        auth: auth,
        parser: parser);
  }

  /// Stores the auth object, such as a JWT Token String,
  /// and updates the authentication state [AuthManager.isAuthenticated] to `true`.
  /// It does not assume anything about the auth object, and
  /// therefore can be used to store any kind of auth object.
  /// Make sure to set the [authManager] accordingly to store the
  /// kind of object you want to use.
  Future authenticate(Object token) async {
    if (_authManager != null) {
      await _authManager!.authenticate(token);
    } else {
      throw UnimplementedError(
          'AuthManager is not set. Please set the initialise AuthManager before using this method');
    }
  }

  /// Removes the auth object and updates the authentication state
  /// [AuthManager.isAuthenticated] to `false`.
  Future unauthenticate() async {
    if (_authManager != null) {
      await _authManager?.unauthenticate();
    } else {
      throw UnimplementedError(
          'AuthManager is not set. Please set the initialise AuthManager before using this method');
    }
  }

  /// Returns the authentication state of the application.
  bool get isAuthenticated {
    if (_authManager != null) {
      return _authManager!.isAuthenticated;
    }
    throw Exception(
        'AuthManager is not set. Please set the initialise AuthManager before using this method');
  }

  _killRequest(Object id) {
    _worker
        .killRequest(id)
        .then((value) => _requestQueueManager.removeFromQueue(id));
  }
}
