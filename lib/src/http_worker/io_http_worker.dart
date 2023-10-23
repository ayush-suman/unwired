import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http_worker/http_worker.dart';
import 'package:unwired/src/store_managers/io_store_manager.dart';

import '../utils.dart';

/// This implementation of [HttpWorker] is used to handle http requests in a
/// separate [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY). By default,
/// it is used by native devices as the web platform does not support
/// [Isolate](https://www.youtube.com/watch?v=vl_AaCgudcY)s.
class DefaultHttpWorker extends HttpWorker {
  DefaultHttpWorker({this.debug = true}): super();

  final bool debug;
  final RequestStoreManager requestStoreManager = RequestStoreManager();
  late final HttpClient client;

  @override
  Future init() async {
    client = HttpClient();
  }

  @override
  (Completer<Response<T>>, {Object? meta}) processRequest<T>(
      {required int id,
      required RequestMethod method,
      required Uri url,
      Map<String, String>? header,
      Object? body,
      Parser<T>? parser,
      Map<String, Object?>? meta}) {

    final Completer<Response<T>> completer = Completer<Response<T>>();


    client.openUrl(method.string, url).then((HttpClientRequest request) async {
      requestStoreManager.storeHttpRequest(requestId: id, request: request);
      try {
        if (header != null) {
          header.forEach((key, value) {
            request.headers.add(key, value);
          });
        }
        if (body != null) {
          final Encoding encoding = encodingForCharset(request.headers.contentType?.charset);
          if (body is Map) {
            if (request.headers.contentType == null) {
              request.headers.contentType = ContentType.parse('application/x-www-form-urlencoded');
              request.write(encoding.encode(mapToQuery(body.cast<String, String>())));
            } else if (request.headers.contentType == ContentType.parse('application/x-www-form-urlencoded')) {
              request.write(encoding.encode(mapToQuery(body.cast<String, String>())));
            } else if (request.headers.contentType == ContentType.parse('multipart/form-data')) {
              final String boundary = 'dart-http-boundary';
              request.headers.contentType = ContentType('multipart', 'form-data', parameters: {'boundary': boundary});
              body.forEach((key, value) {
                request.write(encoding.encode('--$boundary\r\n'));
                request.write(encoding.encode('Content-Disposition: form-data; name="$key"\r\n\r\n'));
                request.write(encoding.encode('$value\r\n'));
              });
              request.write(encoding.encode('--$boundary--'));
            } else if (request.headers.contentType == ContentType.json) {
              request.write(encoding.encode(jsonEncode(body)));
            } else {
              request.write(encoding.encode(body.toString()));
            }
          } else if (body is List) {
            if (body is List<int>) {
              request.write(body);
            } else if (request.headers.contentType == ContentType.json) {
              request.write(encoding.encode(jsonEncode(body)));
            } else {
              request.write(body.cast<int>());
            }
          } else {
            final String bodyString = body.toString();
            request.write(encoding.encode(bodyString));
          }
        }
        final HttpClientResponse response = await request.close();
        final Completer<Uint8List> responseCompleter = Completer<Uint8List>();
        final sink = ByteConversionSink.withCallback((bytes) {
          responseCompleter.complete(Uint8List.fromList(bytes));
        });
        response.listen(sink.add, onError: completer.completeError, onDone: sink.close);
        final Uint8List bytes = await responseCompleter.future;
        final Encoding encoding = encodingForCharset(response.headers.contentType?.charset);
        final String responseBody = encoding.decode(bytes);
        final parsedBody = parser?.parse(responseBody);
        completer.complete(Response<T>(status: response.statusCode, data: parsedBody ?? body as T));
        requestStoreManager.removeFromStore(id);
      } catch (e) {
        completer.complete(Response<T>(status: -1, error: e));
        requestStoreManager.removeFromStore(id);
      }
    });

    return (completer, meta: null);
  }

  @override
  Future killRequest(int id) async {
    requestStoreManager.cancelRequest(requestId: id);
  }

  @override
  destroy() {
    client.close();
  }
}