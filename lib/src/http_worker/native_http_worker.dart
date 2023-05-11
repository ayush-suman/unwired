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

  late final Isolate _isolate;
  late final SendPort _sendPort;

  void getDataAndParse(dynamic message) {
    final data = (message as Map<String, Object?>);

    final Object id = data[ID]!;
    final RequestMethod method = data[METHOD]! as RequestMethod;
    final Uri url = data[URL]! as Uri;
    final Map<String, String>? header = data[HEADER] as Map<String, String>?;
    final body = data[BODY];
    final Parser<dynamic>? parser = data[PARSER] as Parser<dynamic>?;
    final SendPort sendPort = data[SEND_PORT] as SendPort;

    switch (method) {
      case RequestMethod.get:
        http.get(url, headers: header).then((value) {
          try {
            final json = jsonDecode(value.body);
            final data = parser?.parse(json);
            sendPort.send(
                {ID: id, DATA: data ?? json, STATUS_CODE: value.statusCode});
          } catch (e) {
            sendPort.send({ID: id, STATUS_CODE: value.statusCode, ERROR: e});
          }
        },
            onError: (e) => sendPort.send({
                  ID: id,
                  STATUS_CODE: -1,
                  ERROR: e,
                }));
        break;
      case RequestMethod.post:
        http.post(url, headers: header, body: body).then((value) {
          try {
            final json = jsonDecode(value.body);
            final data = parser?.parse(json);
            sendPort.send(
                {ID: id, DATA: data ?? json, STATUS_CODE: value.statusCode});
          } catch (e) {
            sendPort.send({ID: id, STATUS_CODE: value.statusCode, ERROR: e});
          }
        },
            onError: (e) => sendPort.send({
                  ID: id,
                  STATUS_CODE: -1,
                  ERROR: e,
                }));
        break;
      case RequestMethod.put:
        http.put(url, headers: header, body: body).then((value) {
          try {
            final json = jsonDecode(value.body);
            final data = parser?.parse(json);
            sendPort.send(
                {ID: id, DATA: data ?? json, STATUS_CODE: value.statusCode});
          } catch (e) {
            sendPort.send({ID: id, STATUS_CODE: value.statusCode, ERROR: e});
          }
        },
            onError: (e) => sendPort.send({
                  ID: id,
                  STATUS_CODE: -1,
                  ERROR: e,
                }));
        break;
      case RequestMethod.delete:
        http.delete(url, headers: header, body: body).then((value) {
          try {
            final json = jsonDecode(value.body);
            final data = parser?.parse(json);
            sendPort.send(
                {ID: id, DATA: data ?? json, STATUS_CODE: value.statusCode});
          } catch (e) {
            sendPort.send({ID: id, STATUS_CODE: value.statusCode, ERROR: e});
          }
        },
            onError: (e) => sendPort.send({
                  ID: id,
                  STATUS_CODE: -1,
                  ERROR: e,
                }));
        break;
      case RequestMethod.patch:
        http.patch(url, headers: header, body: body).then((value) {
          try {
            final json = jsonDecode(value.body);
            final data = parser?.parse(json);
            sendPort.send(
                {ID: id, DATA: data ?? json, STATUS_CODE: value.statusCode});
          } catch (e) {
            sendPort.send({ID: id, STATUS_CODE: value.statusCode, ERROR: e});
          }
        },
            onError: (e) => sendPort.send({
                  ID: id,
                  STATUS_CODE: -1,
                  ERROR: e,
                }));
        break;
      case RequestMethod.head:
        http.head(url, headers: header).then((value) {
          try {
            final json = jsonDecode(value.body);
            final data = parser?.parse(json);
            sendPort.send(
                {ID: id, DATA: data ?? json, STATUS_CODE: value.statusCode});
          } catch (e) {
            sendPort.send({ID: id, STATUS_CODE: value.statusCode, ERROR: e});
          }
        },
            onError: (e) => sendPort.send({
                  ID: id,
                  STATUS_CODE: -1,
                  ERROR: e,
                }));
        break;
    }
  }

  @override
  Future init() async {
    final ReceivePort _receivePort = ReceivePort();

    _isolate = await Isolate.spawn<SendPort>((sendPort) {
      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);
      receivePort.listen(getDataAndParse);
    }, _receivePort.sendPort);

    _sendPort = await _receivePort.first;
  }

  @override
  Completer<Response<T>> processRequest<T>(Object id, RequestMethod method,
      Uri url, Map<String, String>? header, Object? body, Parser<T>? parser) {
    Completer<Response<T>> completer = Completer<Response<T>>();

    final ReceivePort receivePort = ReceivePort();

    _storeManager.storeCompleter(requestId: id, completer: completer);

    _sendPort.send({
      ID: id,
      URL: url,
      METHOD: method,
      HEADER: header,
      BODY: body,
      PARSER: parser,
      SEND_PORT: receivePort.sendPort
    });

    receivePort.first.then((data) {
      final dataMap = data as Map<String, Object?>;
      final Object id = dataMap[ID]!;
      final Completer<Response<T>>? completer =
          _storeManager.getRequestCompleter(id);
      if (!(completer?.isCompleted ?? true)) {
        final response = Response<T>(
            data: dataMap[DATA] as T?,
            status: dataMap[STATUS_CODE]! as int,
            error: dataMap[ERROR]);
        completer?.complete(response);
        _storeManager.removeFromStore(id);
      }
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
