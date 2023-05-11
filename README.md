<p align="center">
    <a href="https://github.com/Ayush-Suman/unwired/actions"><img src="https://github.com/Ayush-Suman/unwired/workflows/Tests/badge.svg" alt="Tests Status"></a>
    <a href="https://github.com/Ayush-Suman/unwired"><img src="https://img.shields.io/github/stars/Ayush-Suman/unwired.svg?style=flat&logo=github&colorB=deeppink&label=stars" alt="Star on Github"></a>
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-purple.svg" alt="License: MIT"></a>
</p>

# Unwired <img src="https://em-content.zobj.net/source/animated-noto-color-emoji/356/high-voltage_26a1.gif" height=50px />
[![Pub](https://img.shields.io/pub/v/unwired.svg)](https://pub.dev/packages/unwired)

Fast and minimalistic Dart HTTP client library for

- creating cancellable HTTP requests
- managed authentication
- supported multithreaded requests and parsing.

[Unwired] ⚡ is designed to be easy to use while also being super flexible and customizable. It is built on top of [http](https://pub.dev/packages/http) package.

## Features
- [x] Cancellable HTTP requests
- [x] Authentication Manager
- [x] Data Parsing
- [x] Multithreaded Requests
- [ ] Interceptors


## Usage

### Initialising

In Unwired, requests are made using `RequestHandler()` object. However, before you can make any HTTP request, you should initialise the object. Initialising calls the `init()` functions of the `AuthManager` if you are using any, and the `HttpWorker` which processes your HTTP requests.

```dart
final requestHandler = RequestHandler(); // Debug Http Worker will be used since no Http Worker is passed in the constructor
await requestHandler.initialise(); // Once the future completes, you can start making requests using this requestHandler object
```

### Get Request

```dart
final cancellable = requestHandler.get(
        url: "https://api.nasa.gov/planetary/apod", 
        params: {"api_key": "YOUR_API_KEY"}
    );

final response = await cancellable.response;
```

Or you can use the `request` method to make the request.

```dart
final cancellable = requestHandler.request(
        method = RequestMethod.get,
        url = "https://api.nava.gov/planetary/apod",
        params = {"api_key", "YOUR_API_KEY"}
    );
```

### Post Request

POST request will be similar to the GET request. You can pass `body` to the method as well.

```dart
final cancellable = requestHandler.post(
        url: "...",
        body: ... // Body can be of any type
    );

final response = await cancellable.response;
```

Similar to the case with GET request, you can use `request` to make the POST request. `request` method can be used to call other HTTP requests such as DELETE, PUT, PATCH etc.

### Cancelling Request

Cancelling is as simple as calling `cancel` method on `Cancellable` object. This will cause the `Response` object to return immediately with `isCancelled` set to true.

```dart
cancellable.cancel();

final response = await cancellable.response();

print(response.isCancelled); // TRUE
```


### Data Parsing

To parse a data in Unwired requests, you should create a `Parser` object that tells the library how to parse the data.

```dart
class APODParser extends Parser<APOD> {

@override
APOD parse(Object data) {
    // Parse your data into your desired object (APOD in this case) here.
    // Using generators like freezed for your data class will give you a nice function to parse the data from JSON.
    // You can call that function here or throw if parsing fails. The error should be caught by the HTTP Worker 
    // And packed into the Response object.
    
    return apod;
}

}
```

### Using Managed Auth

Unwired supports managed authentication. You can create and use your own implementation of `AuthManager` class to manage the authentication in application and requests.

```dart
class TokenAuthManager extends AuthManager {
  TokenAuthManager({required this.secureStorage}) {
    secureStorage.read(key: _key).then((value) {
      _token = value;
      _completer.complete();
    });
  }

  final FlutterSecureStorage secureStorage;

  final Completer<void> _completer = Completer<void>();

  Future synchronize() {
    return _completer.future;
  }

  String _key = 'a239jakps';
  set key(String k) {
    _key = k;
  }

  String? _token;

  @override
  String? get authObject => _token;

  Future _saveToken(String token) async {
    await secureStorage.write(key: _key, value: token);
    _token = token;
  }

  Future _deleteToken() async {
    await secureStorage.delete(key: _key);
    _token = null;
  }

  Future authenticate(dynamic token) async {
    if (token is String) {
      _saveToken(token);
    } else {
      throw UnsupportedError(
          'Token of type ${token.runtimeType} is not supported');
    }
  }

  Future unauthenticate() async {
    await _deleteToken();
  }

  @override
  bool get isAuthenticated => _token != null;

  String Function(String? token) _tokenParser =
      (token) => token != null ? 'Bearer $token' : '';

  /// This function is used to parse the [authObject] to include any keyword
  /// such as 'Bearer ' along with the [String] token in the `Authorization`
  /// header of a request depending on the type of token.
  set tokenParser(String Function(String? token) parser) {
    _tokenParser = parser;
  }

  @override
  String get parsedAuthObject => _tokenParser(_token);
}
```

Pass your implementation of `AuthManager` to the `RequestHandler`.

```dart
final requestHandler = RequestHandler(authManager: TokenAuthManager());
```

Now you can access the functions like `authenticate` and `unauthenticate` to manage the auth state of your app.

```dart
final token = ... // Some request to get your token
requestHandler.authenticate(token);
```

To make authenticated requests, simply set the `auth` argument of the `request` or `get` or `post` methods to true. This will automatically include the `parsedAuthObject` to the Authentication header of the request.
```dart
final cancellable = requestHandler.get(url: "...", auth: true);
```

## FAQs
### Is it safe to use in production?

Yes. [Unwired] is stable and actively maintained.

## Contributing

Open source projects like Unwired thrive on contributions from the community. Any contribution you make is **greatly appreciated**. 

Here are the ways you can be a part of the development of Unwired

- Report bugs and scenarios that are difficult to implement
- Report parts of the documentation that are unclear
- Fix typos/grammar mistakes
- Update the documentation / add examples
- Implement new features by making a pull-request
- Add test cases for existing features


## Sponsors

This is where your logo could be! [Sponsor] Unwired

[sponsor]: https://github.com/sponsors/Ayush-Suman
[unwired]: https://github.com/Ayush-Suman/unwired
[doc]: https://unwired.ayushsuman.com
