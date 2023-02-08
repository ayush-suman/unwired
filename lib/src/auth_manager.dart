import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthManager<T> {
  T get authObject;

  Future authorize(T authObject);

  Future unauthorize();

  bool get isAuthorised;

  Future synchronize();
}

class TokenAuthManager extends AuthManager<String> {
  TokenAuthManager({required this.secureStorage}) {
    secureStorage.read(key: _key).then(
            (value){
              _token = value;
              _completer.complete();
            });
  }
  
  final FlutterSecureStorage secureStorage;

  Completer<void> _completer = Completer<void>();

  /// Call and await this to ensure correct value from [isAuthorised]
  Future synchronize() {
    return _completer.future;
  }

  String _key = 'a239jakps';
  set key(String k) {
    _key = k;
  }
  
  String? _token;

  String Function(String? token) _tokenModifier = (token) => token != null ? 'Bearer $token' : '';
  set tokenModifier(String Function(String? token) modifier) {
    _tokenModifier = modifier;
  }

  String get authObject => _tokenModifier(_token);
  
  Future _saveToken(String token) async{
    await secureStorage.write(key: _key, value: token);
    _token = token;
  }

  Future _deleteToken() async{
    await secureStorage.delete(key: _key);
    _token = null;
  }

  Future authorize(dynamic token) async {
    if (token is String) {
      _saveToken(token);
    } else {
      throw UnsupportedError('Token of type ${token.runtimeType} is not supported');
    }
  }

  Future unauthorize() async {
    await _deleteToken();
  }

  bool get isAuthorised => _token != null;
} 