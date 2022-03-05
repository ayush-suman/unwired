import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';


const String _TOKEN = 'Token';
final FlutterSecureStorage _flutterSecureStorage = FlutterSecureStorage();

String? _token;

bool _updated = false;

Future<String?> get token async {
  if(!_updated){
    _token = await _flutterSecureStorage.read(key: _TOKEN);
    _updated = true;
  }
  return _token;
}


Future saveToken(String Token) async{
  await _flutterSecureStorage.write(key: _TOKEN, value: Token);
  _updated = false;
}

Future deleteToken() async{
  await _flutterSecureStorage.delete(key: _TOKEN);
  _updated = false;
}

