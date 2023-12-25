## [0.9.7] - 25th Dec 2023.
* Add support for optional host and port in HTTP Worker.

## [0.9.5] - 23rd Oct 2023.
* Updated Default HTTP Worker for io devices to remove multithreaded supported.
* Multithreaded HTTP Worker is now available as a separate package `multithreaded_http_worker`.

## [0.9.4] - 7th June 2023.
* Remove Auth Manager apis from Request Handler

## [0.9.1] - 1st June 2023.
* RequestHandler's request, get and post functions now return GenericRequest<K, T> instead of Cancellable<T>.
* GenericRequest<K, T> is an alias of a record that contains request id, controller (to cancel ongoing requests) and Future of response.
* RequestHandler<int> can use Request<T>, an alias of GenericRequest<int, T> as the return of the functions.

## [0.9.0] - 31st May 2023.
* HTTP Worker now uses dart:io and dart:html to support HTTP requests.
* Removed dependency on http package.

## [0.8.5] - 13th May 2023.
* RequestHandler now makes use of record to return Object? meta along with Completer<Response>. 

## [0.8.0] - 9th May 2023.
* Native HTTP Worker Fixed

## [0.7.0] - 7th May 2023.
* Added doc comments.

## [0.6.0] - 26th April 2023.
* First Complete Implementation of the new Unwired ⚡ library
* Needs documentation

## [0.2.0] - 5th March 2022.
* Using Flutter Secure Storage across all platforms

## [0.1.3] - 14th May 2021.
* CallType (GET, POST, DEL etc) and Content Type of network calls moved to URL route class.

## [0.1.0] - 13th May 2021.
* Make network request with disposable feature and multi-threading.
