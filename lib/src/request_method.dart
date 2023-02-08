enum RequestMethod {
 get,
 post,
 put,
 delete,
 option,
 trace,
 patch
}

extension Str on RequestMethod {
 String get string => name.toUpperCase();
}