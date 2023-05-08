import 'dart:async';
import 'dart:convert';

import 'http_worker.dart';
import '../parser.dart';
import '../request_method.dart';
import '../response.dart';
import 'package:http/http.dart' as http;

/// An [HttpWorker] implementation for web platform. This is perhaps the
/// simplest implementation of [HttpWorker]. You can override the default
/// setting in [RequestHandler] to use this for both web and native platforms
/// for its simplicity.
class DefaultHttpWorker extends HttpWorker {
  @override
  Future init() async {}

  @override
  Completer<Response<T>> processRequest<T>(Object id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser) {
    Completer<Response<T>> completer = Completer<Response<T>>();

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          if (!completer.isCompleted) {
            final json = jsonDecode(value.body);
            try {
              T? data = parser?.parse(json);
              completer.complete(
                  Response(status: value.statusCode, data: data ?? json));
            } catch (e) {
              if (!completer.isCompleted) {
                completer
                    .complete(Response(status: value.statusCode, error: e));
              }
            }
          }
        }, onError: (e) {
          if (!completer.isCompleted)
            completer.complete(Response(status: -1, error: e));
        });
        break;
    }
    return completer;
  }

  @override
  Future killRequest(Object id) async {}

  @override
  destroy() {}
}
