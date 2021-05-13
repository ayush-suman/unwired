import 'package:unwired/json_model.dart';


/// Class containing response model constructor ([_jsonModelConstructor]), [route] and base [URL]
/// Extend with (Base) [URL] defined only in super to avoid passing every time you create an instance of [URLRote].
/// Create an instance of [URLRoute] for each endpoint.
abstract class URLRoute<T>{

  final String URL;
  final String route;

  final JSONModelConstructor<T> _jsonModelConstructor;

  T getModelClass(Map<String, dynamic> data) => _jsonModelConstructor.fromMap(data);


  URLRoute(this.URL, this.route, this._jsonModelConstructor);
}