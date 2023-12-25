import 'dart:async';

import 'package:http_worker/http_worker.dart';
import 'package:auth_manager/auth_manager.dart';
import 'package:queue_manager/queue_manager.dart';
import 'package:unwired/src/http_worker/http_worker.dart';
import 'package:unwired/src/queue_manager.dart';
import 'package:unwired/src/cancellable.dart';

typedef Request<T> = ({
  int id,
  Cancellable<T> controller,
  Future<Response<T>> response
});


/// This is used to create HTTP requests.
class RequestHandler {
  RequestHandler(
      {
      /// Should start with http:// or https://
      String? baseUrl,

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
      HttpWorker<int>? worker,

      /// [QueueManager] contains the strategy used to store the ongoing requests'
      /// meta data. This can be used to limit the maximum number of ongoing
      /// requests or to implement your own logic for managing the queue.
      ///
      /// [RequestIdQueueManager] is the default value of the [requestQueueManager].
      QueueManager<int>? requestQueueManager}) {
    assert((baseUrl != null) ? baseUrl.startsWith('http') : true,
        'baseUrl cannot be null');
    _baseUrl = (baseUrl!=null) ? Uri.parse(baseUrl) : null;
    _authManager = authManager;
    _worker = worker ?? DefaultHttpWorker();
    _requestQueueManager = requestQueueManager ?? RequestIdQueueManager();
  }

  late final Uri? _baseUrl;

  /// [QueueManager] contains the strategy used to store the ongoing requests'
  /// meta data. This can be used to limit the maximum number of ongoing
  /// requests or to implement your own logic for managing the queue
  late final QueueManager<int> _requestQueueManager;

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
      _worker.init(host: _baseUrl?.host, port: _baseUrl?.port)
    ]);
  }

  /// Function to make a network request and returns the Request Id and a [Cancellable]. The
  /// [Cancellable] contains the [Future] of the [Response] of the request, and
  /// a [Cancellable.cancel] method to cancel the ongoing request before it completes.
  Request<T> request<T>(

      /// The url can be the path of the endpoint or the full url.
      /// If the url is a path, the [baseUrl] is prepended to the url.
      /// If the url is a full url, the [baseUrl] is ignored.
      String path,
      {RequestMethod method = RequestMethod.get,
      Map<String, String>? params,
      Map<String, String>? header,
      Object? body,
      bool auth = false,
      Parser<T>? parser,
      Map<String, Object?>? meta}) {
    if (meta == null) meta = {};
    int id = _requestQueueManager.createNewQueueObject();

    Uri url = Uri.parse(path);

    // Add params to url for parsing into Uri
    url.replace(queryParameters: url.queryParameters..addAll(params ?? {}));

    // Add baseUrl if url is a path
    if (_baseUrl != null && url.host == '') {
      assert(_baseUrl!.host != '', 'No baseUrl passed');
      url = _baseUrl!.resolveUri(url);
      meta.addAll({"using_base_url": true});
    } else {
      assert(url.host != '', 'No host passed');
      meta.addAll({"using_base_url": false});
    }

    // Add auth token if auth is true
    if (auth)
      if (_authManager != null) {
        header == null
            ? header = {'Authorization': _authManager!.parsedAuthObject}
            : header.addAll({'Authorization': _authManager!.parsedAuthObject});
      } else {
        throw UnsupportedError(
            'AuthManager is not set. Please set the initialise AuthManager before using this method');
      }

    (Completer<Response<T>>, {Object? meta}) record = _worker.processRequest<T>(
        id: id,
        method: method,
        url: url,
        header: header,
        body: body,
        parser: parser,
        meta: meta);

    return (
      id: id,
      controller: Cancellable(record.$1, meta: record.meta, onCancel: () {
        _killRequest(id);
      }),
      response: record.$1.future
    );
  }

  /// Function to make a GET network request
  Request<T> get<T>(

      /// The url can be the path of the endpoint or the full url.
      /// If the url is a path, the [baseUrl] is prepended to the url.
      /// If the url is a full url, the [baseUrl] is ignored.
      String url,
      {Map<String, String>? params,
      Map<String, String>? header,
      bool auth = false,
      Parser<T>? parser}) {
    return request(url,
        method: RequestMethod.get, params: params, auth: auth, parser: parser);
  }

  /// Function to make a POST network request
  Request<T> post<T>(

      /// The url can be the path of the endpoint or the full url.
      /// If the url is a path, the [baseUrl] is prepended to the url.
      /// If the url is a full url, the [baseUrl] is ignored.
      String url,
      {Map<String, String>? params,
      Map<String, String>? header,
      Object? body,
      bool auth = false,
      Parser<T>? parser}) {
    return request(url,
        method: RequestMethod.post,
        params: params,
        body: body,
        auth: auth,
        parser: parser);
  }

  _killRequest(int id) {
    _worker
        .killRequest(id)
        .then((value) => _requestQueueManager.removeFromQueue(id));
  }
}
