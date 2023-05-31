export 'package:unwired/src/http_worker/stub_http_worker.dart'
    if (dart.library.io) 'package:unwired/src/http_worker/io_http_worker.dart'
    if (dart.library.html) 'package:unwired/src/http_worker/web_http_worker.dart';