enum RequestMethod { get, post, put, delete, patch, head }

extension Str on RequestMethod {
  String get string => name.toUpperCase();
}
