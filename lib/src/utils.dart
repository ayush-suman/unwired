import 'dart:convert';

/// Converts a [Map] from parameter names to values to a URL query string.
///
///     mapToQuery({"foo": "bar", "baz": "bang"});
///     //=> "foo=bar&baz=bang"
String mapToQuery(Map<String, String> map, {Encoding? encoding}) {
  var pairs = <List<String>>[];
  map.forEach((key, value) => pairs.add([
    Uri.encodeQueryComponent(key, encoding: encoding ?? utf8),
    Uri.encodeQueryComponent(value, encoding: encoding ?? utf8)
  ]));
  return pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
}

/// Returns the [Encoding] that corresponds to [charset].
///
/// Returns [fallback] if [charset] is null or if no [Encoding] was found that
/// corresponds to [charset].
Encoding encodingForCharset(String? charset, [Encoding fallback = latin1]) {
  if (charset == null) return fallback;
  return Encoding.getByName(charset) ?? fallback;
}