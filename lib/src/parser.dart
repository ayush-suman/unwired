/// Extend this class to create your own [Parser].
///
/// [Parser] is used by [HttpWorker] to parse the response of a request.
///
/// [parse] function converts the body of the response into desired data class.
/// It can throw an [Exception] if the response body is not in the desired
/// format. This exception will be caught by [HttpWorker] and the [Response] will
/// update its [Response.error] value.
abstract class Parser<T> {
  T parse(Object data);
}
