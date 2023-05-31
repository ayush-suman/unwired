import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:http_worker/http_worker.dart';
import 'package:unwired/src/store_managers/io_store_manager.dart';
import 'package:unwired/src/constants.dart';

import '../utils.dart';

/// This implementation of [HttpWorker] is used to handle http requests in a
/// separate [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY). By default,
/// it is used by native devices as the web platform does not support
/// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s.
class DefaultHttpWorker<K> extends HttpWorker<K> {
  late final Isolate _isolate;
  late final SendPort _sendPort;

  void _getResponseOrKill(dynamic message, RequestStoreManager<K> requestStoreManager) {
    final data = (message as Map<String, Object?>);

    final K id = data[ID]! as K;
    final String action = data[ACTION]! as String;

    if (action == 'kill') {
      _cancelRequest(requestId: id, requestStoreManager: requestStoreManager);
      return;
    }

    final RequestMethod method = data[METHOD]! as RequestMethod;
    final Uri url = data[URL]! as Uri;
    final Map<String, String>? header = data[HEADER] as Map<String, String>?;
    final Object? requestBody = data[BODY];
    final Parser<dynamic>? parser = data[PARSER] as Parser<dynamic>?;
    final SendPort sendPort = data[SEND_PORT]! as SendPort;

    final HttpClient client = HttpClient();

    client.openUrl(method.string, url).then((HttpClientRequest request) async {
      requestStoreManager.storeHttpRequest(requestId: id, request: request);
      try {
        if (header != null) {
          header.forEach((key, value) {
            request.headers.add(key, value);
          });
        }
        if (requestBody != null) {
          final Encoding encoding = encodingForCharset(request.headers.contentType?.charset);
          if (requestBody is Map) {
            if (request.headers.contentType == null) {
              request.headers.contentType = ContentType.parse('application/x-www-form-urlencoded');
              request.write(encoding.encode(mapToQuery(requestBody.cast<String, String>())));
            } else if (request.headers.contentType == ContentType.parse('application/x-www-form-urlencoded')) {
              request.write(encoding.encode(mapToQuery(requestBody.cast<String, String>())));
            } else if (request.headers.contentType == ContentType.parse('multipart/form-data')) {
              final String boundary = 'dart-http-boundary';
              request.headers.contentType = ContentType('multipart', 'form-data', parameters: {'boundary': boundary});
              requestBody.forEach((key, value) {
                request.write(encoding.encode('--$boundary\r\n'));
                request.write(encoding.encode('Content-Disposition: form-data; name="$key"\r\n\r\n'));
                request.write(encoding.encode('$value\r\n'));
              });
              request.write(encoding.encode('--$boundary--'));
            } else if (request.headers.contentType == ContentType.json) {
              request.write(encoding.encode(jsonEncode(requestBody)));
            } else {
              request.write(encoding.encode(requestBody.toString()));
            }
          } else if (requestBody is List) {
            if (requestBody is List<int>) {
              request.write(requestBody);
            } else if (request.headers.contentType == ContentType.json) {
              request.write(encoding.encode(jsonEncode(requestBody)));
            } else {
              request.write(requestBody.cast<int>());
            }
          } else {
              final String bodyString = requestBody.toString();
              request.write(encoding.encode(bodyString));
          }
        }
        final HttpClientResponse response = await request.close();
        final Completer<List<int>> completer = Completer<List<int>>();
        final sink = ByteConversionSink.withCallback((bytes) {
          completer.complete(Uint8List.fromList(bytes));
        });
        response.listen(sink.add, onError: completer.completeError, onDone: sink.close);
        final List<int> bytes = await completer.future;
        final Encoding encoding = encodingForCharset(response.headers.contentType?.charset);
        final String body = encoding.decode(bytes);
        final parsedBody = parser?.parse(body);
        sendPort.send({
          ID: id,
          DATA: parsedBody ?? body,
          STATUS_CODE: response.statusCode
        });
        requestStoreManager.removeFromStore(id);
      } catch (e) {
        sendPort.send({ID: id, STATUS_CODE: -1, ERROR: e});
        requestStoreManager.removeFromStore(id);
      }
    });
  }

  void _cancelRequest({required K requestId, required RequestStoreManager requestStoreManager, int tryCount = 0}) {
    try {
      if (tryCount > 3) {
        return;
      }
      requestStoreManager.cancelRequest(requestId: requestId);
    } catch (e) {
      Future.delayed(Duration(seconds: 1), () {
        _cancelRequest(requestId: requestId, requestStoreManager: requestStoreManager, tryCount: tryCount + 1);
      });
    }
  }

  @override
  Future init() async {
    final ReceivePort _receivePort = ReceivePort();
    _isolate = await Isolate.spawn<SendPort>((sendPort) {
      final RequestStoreManager<K> _storeManager = RequestStoreManager<K>();

      final receivePort = ReceivePort();
      sendPort.send(receivePort.sendPort);

      receivePort.listen((message) {
        _getResponseOrKill(message, _storeManager);
      });
    }, _receivePort.sendPort);
    _sendPort = await _receivePort.first;
  }

  @override
  (Completer<Response<T>>, {Object? meta}) processRequest<T>(
      {required K id,
      required RequestMethod method,
      required Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser,
      Object? meta}) {

    final Completer<Response<T>> completer = Completer<Response<T>>();

    final ReceivePort _responsePort = ReceivePort();

    _sendPort.send({
      ID: id,
      URL: url,
      METHOD: method,
      HEADER: header,
      BODY: body,
      PARSER: parser,
      ACTION: 'request',
      SEND_PORT: _responsePort.sendPort,
    });

    _responsePort.first.then((data) {
      final dataMap = data as Map<String, Object?>;
      if (!(completer.isCompleted)) {
        final response = Response<T>(
            data: dataMap[DATA] as T?,
            status: dataMap[STATUS_CODE]! as int,
            error: dataMap[ERROR]);
        completer.complete(response);
      }
    });

    return (completer, meta: null);
  }

  @override
  Future killRequest(K id) async {
    _sendPort.send({
      ID: id,
      ACTION: 'kill',
    });
  }

  @override
  destroy() {
    _isolate.kill();
  }
}