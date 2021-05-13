import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:localstorage/localstorage.dart';


const String _TOKEN = 'Token';
final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();
final LocalStorage _localStorage = LocalStorage("token.json");

String? _token;

bool _updated = false;

Future<String?> get token async {
  if(!_updated){
    if(kIsWeb){
      await _localStorage.ready;
      _token = _localStorage.getItem(_TOKEN);
    }else {
      _token = await _flutterSecureStorage.read(key: _TOKEN);
    }
    _updated = true;
  }
  return _token;
}


Future saveToken(String Token) async{
    if(kIsWeb){
      await _localStorage.ready;
      _localStorage.setItem(_TOKEN, Token);
    }else {
      await _flutterSecureStorage.write(key: _TOKEN, value: Token);
    }
    _updated = false;
}

Future deleteToken() async{
    if(kIsWeb){
      await _localStorage.ready;
      _localStorage.deleteItem(_TOKEN);
    }else {
      await _flutterSecureStorage.delete(key: _TOKEN);
    }
    _updated = false;
}

