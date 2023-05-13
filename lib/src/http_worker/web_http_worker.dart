import 'dart:async';

import 'package:http_worker/http_worker.dart';
import 'package:http/http.dart' as http;

/// An [HttpWorker] implementation for web platform. This is perhaps the
/// simplest implementation of [HttpWorker]. You can override the default
/// setting in [RequestHandler] to use this for both web and native platforms
/// for its simplicity.
class DefaultHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  (Completer<Response<T>>, {Object? meta}) processRequest<T>(
      {required Object id,
        required RequestMethod method,
        required Uri url,
        Map<String, String>? header,
        Object? body,
        Parser<T>? parser,
        Object? meta
      }) {
    Completer<Response<T>> completer = Completer<Response<T>>();

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response<T>(status: -1, error: e));
        });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response<T>(status: -1, error: e));
        });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response<T>(status: -1, error: e));
        });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response<T>(status: -1, error: e));
        });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response<T>(status: -1, error: e));
        });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            try {
              T? data = parser?.parse(value.body);
              completer.complete(
                  Response<T>(status: value.statusCode, data: data ?? value.body as T));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response<T>(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response<T>(status: -1, error: e));
        });
        break;
    }
    return (completer, meta: null);
  }

  @override
  Future killRequest(Object id) async {}

  @override
  destroy() {}
}
