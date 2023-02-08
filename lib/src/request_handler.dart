import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:unwired/src/auth_manager.dart';
import 'package:unwired/src/http_worker.dart';
import 'package:unwired/src/queue_manager.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart';

class RequestHandler {
  RequestHandler._();
  static late RequestHandler _instance = RequestHandler._();
  factory RequestHandler() {
    return _instance;
  }

  Future initialise() async {
    return Future.wait([
      _authManager.synchronize(),
      _worker.init()
    ]);
  }

  QueueManager<int> _requestQueueManager = RequestIdQueueManager();
  /// [QueueManager] tells the strategy used to store the ongoing requests.
  /// This can be used to limit the maximum number of ongoing requests
  /// or to implement your own logic for managing the queue
  set requestQueueManager(QueueManager<int> queueManager) {
    _requestQueueManager = queueManager;
  }

  HttpWorker _worker = kDebugMode
      ? DebugHttpWorker()
      : kIsWeb
          ? WebHttpWorker()
          : NativeHttpWorker();
  /// [HttpWorker] does the job of processing requests.
  /// It can be used to process requests on separate
  /// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)
  /// or a pool of Isolates
  /// or for debugging and testing
  set worker(HttpWorker worker) {
    _worker = worker;
  }

  AuthManager<String> _authManager =
      TokenAuthManager(secureStorage: FlutterSecureStorage());
  /// [AuthManager] is used to store token or manage the state of authentication
  /// for an application. One can create their own [AuthManager] to create
  /// their own implementation of managing the authentication or to not manage
  /// authentication at all
  set authManager(AuthManager<String> manager) {
    _authManager = manager;
  }


  /// Function to make a network request
  Cancellable request(
      {RequestMethod method = RequestMethod.get,
      required String url,
      Map<String, String>? params,
      Map<String, String>? header,
      Object? body,
      bool auth = false}) {
    int id = _requestQueueManager.createNewQueueObject();

    // Add params to url for parsing into Uri
    if (url.contains('?')) {
      url = params != null
          ? '$url?${params.entries.map((e) => "'${e.key}'='${e.value}'").join('&')}'
          : url;
    } else {
      url = params != null
          ? '$url&${params.entries.map((e) => "'${e.key}'='${e.value}'").join('&')}'
          : url;
    }
    Uri uri = Uri.parse(url);

    // Add auth token if auth is true
    if (auth)
      header == null
          ? header = {'Authorization': _authManager.authObject}
          : header.addAll({'Authorization': _authManager.authObject});

    Completer<Response> completer = _worker.processRequest(
      id,
      method,
      uri,
      header,
      body
    );

    return Cancellable(completer.future, onCancel: () {
      completer.complete(Response(status: -1, isCancelled: true));
      _killRequest(id);
    });
  }

  /// Function to make a GET network request
  Cancellable get(
      {required String url,
        Map<String, String>? params,
        Map<String, String>? header,
        bool auth = false}) {
    return request(method: RequestMethod.get, url: url, params: params, auth: auth);
  }

  /// Function to make a POST network request
  Cancellable post(
      {required String url,
        Map<String, String>? params,
        Map<String, String>? header,
        Object? body,
        bool auth = false}) {
    return request(method: RequestMethod.post, url: url, params: params, body: body, auth: auth);
  }

  _killRequest(int id) {
    _worker
        .killRequest(id)
        .then((value) => _requestQueueManager.removeFromQueue(id));
  }
}
