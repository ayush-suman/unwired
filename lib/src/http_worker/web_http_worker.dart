import 'dart:async';
import 'dart:convert';

import 'dart:html';
import 'dart:typed_data';

import 'package:http_parser/http_parser.dart';
import 'package:http_worker/http_worker.dart';
import 'package:unwired/src/store_managers/web_store_manager.dart';

import '../utils.dart';

/// An [HttpWorker] implementation for web platform. This is perhaps the
/// simplest implementation of [HttpWorker]. You can override the default
/// setting in [RequestHandler] to use this for both web and native platforms
/// for its simplicity.
class DefaultHttpWorker<K> extends HttpWorker<K> {
  final RequestStoreManager<K> requestStoreManager = RequestStoreManager<K>();

  @override
  Future init() async {}

  @override
  (Completer<Response<T>>, {Object? meta}) processRequest<T>(
      {required K id,
        required RequestMethod method,
        required Uri url,
        Map<String, String>? header,
        Object? body,
        Parser<T>? parser,
        Map<String, Object?>? meta
      }) {
    Completer<Response<T>> completer = Completer<Response<T>>();
    print("Request in process");

    final List<int> bytes = <int>[];

    if (body != null) {
      final Encoding encoding = encodingForCharset((MediaType.parse(header?['content-type']??'text/plain')).parameters['charset']);
      if (body is Map) {
        if (header?['content-type'] == null) {
          if (header == null) {
            header = {'content-type': 'application/x-www-form-urlencoded'};
          } else {
            header['content-type'] = 'application/x-www-form-urlencoded';
          }
          bytes.addAll(encoding.encode(mapToQuery(body.cast<String, String>())));
        } else if (header!['content-type'] == 'application/x-www-form-urlencoded') {
          bytes.addAll(encoding.encode(mapToQuery(body.cast<String, String>())));
        } else if (header['content-type'] == 'multipart/form-data') {
          final String boundary = 'dart-http-boundary';
          header['content-type'] = 'multipart/form-data;boundary=$boundary';
          body.forEach((key, value) {
            bytes.addAll(encoding.encode('--$boundary\r\n'));
            bytes.addAll(encoding.encode('Content-Disposition: form-data; name="$key"\r\n\r\n'));
            bytes.addAll(encoding.encode('$value\r\n'));
          });
          bytes.addAll(encoding.encode('--$boundary--'));
        } else if (header['content-type'] == 'application/json') {
          bytes.addAll(encoding.encode(jsonEncode(body)));
        } else {
          bytes.addAll(encoding.encode(body.toString()));
        }
      } else if (body is List) {
        if (body is List<int>) {
          bytes.addAll(body);
        } else if (header!['content-type'] == 'application/json') {
          bytes.addAll(encoding.encode(jsonEncode(body)));
        } else {
          bytes.addAll(body.cast<int>());
        }
      } else {
        final String bodyString = body.toString();
        bytes.addAll(encoding.encode(bodyString));
      }
    }

    var request = HttpRequest();

    requestStoreManager.storeHttpRequest(requestId: id, request: request);

    request
      ..open(method.string, '$url', async: true)
      ..responseType = 'arraybuffer'
      ..withCredentials = false;
    header?.forEach(request.setRequestHeader);

    request.onLoad.first.then((_) {
      final Uint8List responseBytes = (request.response as ByteBuffer).asUint8List();
      final Encoding encoding = encodingForCharset(MediaType.parse(request.responseHeaders['content-type']??'application/octet-stream').parameters['charset']);
      final String body = encoding.decode(responseBytes);
      final T? parsedBody = parser?.parse(body);
      completer.complete(Response<T>(status: request.status!, data: parsedBody ?? body as T));
      requestStoreManager.removeFromStore(id);
    });

    request.onError.first.then((e) {
      completer.complete(Response<T>(status: -1, error: e));
      requestStoreManager.removeFromStore(id);
    });

    if (bytes.isEmpty) {
      request.send();
    } else {
      request.send(Uint8List.fromList(bytes));
    }
    return (completer, meta: null);
  }

  @override
  Future killRequest(K id) async {
    requestStoreManager.cancelRequest(requestId: id);
  }

  @override
  destroy() {}
}
