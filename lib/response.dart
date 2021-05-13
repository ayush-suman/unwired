import 'dart:async';

import 'package:spider/httpworker.dart';


/// [T] is the return type of response and [J] is the model class for parsing response data
/// In some cases [T] and [J] might be same.
/// These will differ if response is list of something. That something (model class) will be [J] and list (response) will be [T]
class Response<T,J>{
  Response(this._id);
  final int _id;

  /// Dispose the ongoing network call
  /// Clears the call from network request queue
  void dispose(){
    SpiderWeb.sendRequest(_id);
  }

  /// Complete onGoing network call with result.
  /// Use for testing only
  void completeWith(dynamic value){
    if(value is Exception || value is Error){
      _response.completeError(value);
      return;
    }
    if(value is List){
      _response.complete(value.cast<J>() as T);
    }else{
      _response.complete(value);
    }
  }

  Completer<T> _response = Completer<T>();

  /// Response body or error
  Future<T> get response => _response.future;

}