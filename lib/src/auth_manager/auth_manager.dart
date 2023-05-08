import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// This is the base class to store the authentication state and
/// credentials of the application.
///
/// Extend this class to implement your own authentication logic. You can store
/// the [authObject] in any db of your choice, in a [FlutterSecureStorage], or
/// in memory if you don't want to persist it.
abstract class AuthManager<T> {
  const AuthManager();

  T get authObject;

  /// [authenticate] is used to store the [authObject] and update
  /// the [isAuthenticated] state to `true`.
  Future authenticate(T authObject);

  /// [unauthenticate] is used to delete the [authObject] and update the
  /// [isAuthenticated] state to `false`.
  Future unauthenticate();

  /// [isAuthenticated] is used to check the authentication state of the app.
  /// Generally, this would check the value of [authObject] to return the state
  /// of authentication.
  bool get isAuthenticated;

  /// Returns [String] type [authObject] in a format that can be used in the
  /// `Authorization` header of a request.
  String get parsedAuthObject;

  /// [synchronize] is used to ensure that the [authObject] is correctly synced.
  /// Call and await this once in the app lifetime to ensure correct value
  /// from [isAuthenticated] and [authObject]
  Future synchronize();
}

/// This is an implementation of [AuthManager] which stores
/// a [String] type auth object. This is can be used to store a JWT token, for
/// example.
///
/// It uses [FlutterSecureStorage] to store the token in the device securely.
class TokenAuthManager extends AuthManager<String?> {
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
