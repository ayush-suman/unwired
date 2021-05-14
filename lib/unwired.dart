library unwired;

import 'dart:async';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:unwired/httpworker.dart';
import 'package:unwired/response.dart';
import 'package:unwired/tokenhandler.dart' as TokenHandler;
import 'package:unwired/url_route.dart';
import 'calltype.dart';

/// Spider - Handles network tasks such as authenticated calls, response parsing and multi-threading.
class Unwired {

  static late Unwired _spider = Unwired._();

  Unwired._();

  /// Returns Singleton instance of spider
  static Unwired getInstance(){
    return _spider;
  }


  int _MAX_REQUESTS = 256;

  Function(String? token) _modifyToken = (token) => token;

  void setTokenModifier({required Function(String? token) tokenModifier}){
    _modifyToken = tokenModifier;
  }

  Future<String?> get _token async => _modifyToken(await TokenHandler.token);

  Future<bool> get isAuthenticated async => (await TokenHandler.token)!=null;

  /// Should be called while app starts
  /// Otherwise request will not result in any response
  Future initialiseNetwork({Function(String?)? tokenModifier, int? maxReqestQueueSize}) async{
    if(tokenModifier!=null) _modifyToken = tokenModifier;
    if(maxReqestQueueSize!=null) _MAX_REQUESTS = maxReqestQueueSize;
    await UnwiredWeb.init();
  }


  final List<int> _idQueue = [];

  final Random _random = Random();
  int _idGenerator(){
    int rand = _random.nextInt(_MAX_REQUESTS);
    if(_idQueue.length==_MAX_REQUESTS){
      throw Exception("Request Queue Full");
    }
    while(_idQueue.contains(rand)){
      rand = _random.nextInt(_MAX_REQUESTS);
    }
    _idQueue.add(rand);
    return rand;
  }



  /// [T] is the return type of response and [J] is the model class for parsing response data
  /// In some cases [T] and [J] might be same.
  /// These will differ if response is list of something. That something (model class) will be [J] and list (response) will be [T]
  Future<Response<T, J>> request<T, J>({required URLRoute route,
    @deprecated CALLTYPE? call,
    Map<String, String>? param,
    Map<String, dynamic>? header,
    Map<String, dynamic>? body,
    bool auth=false,
    http.Client? client,
  }) async {
    String? token = auth? await _token: "";

    int id = _idGenerator();
    print(id);
    Response<T, J> response = Response<T, J>(id);

    Map<String, dynamic> data = {
      'id':id,
      'route':route,
      'call': call??route.calltype,
      'param':param,
      'header':header,
      'body':body,
      'auth':auth,
      'token': token,
    };
    print(data.runtimeType);
    UnwiredWeb.sendRequest(data, response: response).then((value){
      _idQueue.remove(id);
      response.completeWith(value);
    });
    return response;
  }



  Future authenticate(String token) async{
    await TokenHandler.saveToken(token);
  }

  Future unauthenticate() async{
    await TokenHandler.deleteToken();
  }

}
