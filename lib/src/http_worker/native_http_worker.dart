import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:unwired/src/http_worker/http_worker.dart';
import 'package:unwired/src/parser.dart';
import 'package:unwired/src/request_method.dart';
import 'package:unwired/src/response.dart';
import 'package:unwired/src/store_manager.dart';
import 'package:unwired/src/constants.dart';
import 'package:http/http.dart' as http;

/// This implementation of [HttpWorker] is used to handle http requests in a
/// separate [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY). By default,
/// it is used by native devices as the web platform does not support
/// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s.
class DefaultHttpWorker extends HttpWorker {
  final RequestCompleterStoreManager _storeManager =
      RequestCompleterStoreManager();
  final ReceivePort _receivePort = ReceivePort();
  late final Isolate _isolate;
  late final SendPort _sendPort;

  @override
  Future init() async {
    _isolate = await Isolate.spawn<SendPort>((sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      receivePort.listen((message) {
        final data = (message as Map<String, Object?>);

        final Object id = data[ID]!;
        final RequestMethod method = data[METHOD]! as RequestMethod;
        final Uri url = data[URL]! as Uri;
        final Map<String, String>? header =
            data[HEADER] as Map<String, String>?;
        final body = data[BODY];
        final Parser? parser = data[PARSER] as Parser?;

        switch (method) {
          case RequestMethod.get:
            http.get(url, headers: header).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE:
                      Response(status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send(
                    {ID: id, RESPONSE: (Response(status: -1, error: e))}));
            break;
          case RequestMethod.post:
            http.post(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE:
                      Response(status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send(
                    {ID: id, RESPONSE: (Response(status: -1, error: e))}));
            break;
          case RequestMethod.put:
            http.put(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE:
                      Response(status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send(
                    {ID: id, RESPONSE: (Response(status: -1, error: e))}));
            break;
          case RequestMethod.delete:
            http.delete(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE:
                      Response(status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send(
                    {ID: id, RESPONSE: (Response(status: -1, error: e))}));
            break;
          case RequestMethod.patch:
            http.patch(url, headers: header, body: body).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE:
                      Response(status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send(
                    {ID: id, RESPONSE: (Response(status: -1, error: e))}));
            break;
          case RequestMethod.head:
            http.head(url, headers: header).then((value) {
              final json = jsonDecode(value.body);
              try {
                dynamic data = parser?.parse(json);
                sendPort.send({
                  ID: id,
                  RESPONSE:
                      Response(status: value.statusCode, data: data ?? json)
                });
              } catch (e) {
                sendPort.send({
                  ID: id,
                  RESPONSE: Response(status: value.statusCode, error: e)
                });
              }
            },
                onError: (e) => sendPort.send(
                    {ID: id, RESPONSE: (Response(status: -1, error: e))}));
            break;
        }
      });
    }, _receivePort.sendPort);

    _sendPort = await _receivePort.first;

    _receivePort.listen((data) {
      final dataMap = data as Map<String, Object?>;
      final Object id = dataMap[ID]!;
      final completer = _storeManager.getRequestCompleter(id);
      if (!(completer?.isCompleted ?? true))
        completer?.complete(dataMap[RESPONSE]);
      _storeManager.removeFromStore(id);
    });
  }

  @override
  Completer<Response<T>> processRequest<T>(Object id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser) {
    Completer<Response<T>> completer = Completer<Response<T>>();

    _storeManager.storeCompleter(requestId: id, completer: completer);

    _sendPort.send({
      ID: id,
      URL: url,
      METHOD: method,
      HEADER: header,
      BODY: body,
      PARSER: parser
    });

    return completer;
  }

  @override
  Future killRequest(Object id) async {
    _storeManager.removeFromStore(id);
  }

  @override
  destroy() {
    _isolate.kill();
  }
}
