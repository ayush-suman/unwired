import 'dart:io';

import 'package:unwired/calltype.dart';
import 'package:unwired/json_model.dart';


/// Class containing response model constructor ([_jsonModelConstructor]), [route] and base [URL]
/// Extend with (Base) [URL] defined only in super to avoid passing every time you create an instance of [URLRote].
/// Create an instance of [URLRoute] for each endpoint.
abstract class URLRoute<T>{

  final String URL;
  final String route;
  final CALLTYPE calltype;
  final String? contentType;

  final JSONModelConstructor<T>? _jsonModelConstructor;

  T getModelClass(Map<String, dynamic> data) {
    return  _jsonModelConstructor != null
        ? _jsonModelConstructor!.fromMap(data)
        : data as T;
  }


  URLRoute(this.URL, this.route, this.calltype, this._jsonModelConstructor, {this.contentType});
}

