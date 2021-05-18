import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import 'package:http/io_client.dart';
import 'package:unwired/response.dart';
import 'package:unwired/url_route.dart';
import 'calltype.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UnwiredWeb {
  static final _RequestDataHandler _requestDataHandler = _RequestDataHandler();

  static late ReceivePort _receivePort;
  static late Isolate _isolate;
  static late SendPort _sendPort;

  static late StreamController _streamController;
  static late StreamSubscription _streamSubscription;

  static Completer<void> _isolateReady = Completer<void>();

  static Future<void> get _isReady => _isolateReady.future;


  static Future init() async {
    if (kIsWeb) {
      _streamController = StreamController();
      _streamSubscription = _webEntryFunction(_streamController);
    } else {
      _receivePort = ReceivePort();
      _isolate = await Isolate.spawn(_entryFunction, _receivePort.sendPort);
      _sendPort = await _receivePort.first;
    }
    _isolateReady.complete();
  }

  /// Kills the initialised isolates and streams
  /// Probably should never be called in app lifecycle
  static void destroy() {
    if (kIsWeb) {
      _streamController.close();
      _streamSubscription.cancel();
    } else {
      _receivePort.close();
      _isolate.kill();
    }
  }


  static Future<dynamic> sendRequest(var data, {Response? response}) async {
    if (kIsWeb) {
      StreamController streamController = StreamController();
      if (data is int) {
        _streamController.add([data]);
      } else {
        _streamController.add([data, streamController]);
      }
      dynamic returnValue = await streamController.stream.first;
      streamController.close();
      return returnValue;
    } else {
      await _isReady;
      ReceivePort _responsePort = ReceivePort();
      if (data is int) {
        _sendPort.send([data]);
      } else {
        _sendPort.send([data, _responsePort.sendPort]);
      }
      dynamic returnValue = await _responsePort.first;
      _responsePort.close();
      return returnValue;
    }
  }
}


class _RequestDataHandler with ChangeNotifier{
  Map<int, SendPort> _sendPorts = {};
  Map<int,IOClient> _clients = {};
  Map<int, bool> _isCancelled = {};
  Map<int, StreamController> _streamConts = {};

  List<Map> _datas = [];
  late int newId;

  void addData(List data){
    var reqdata = data[0];
    newId = reqdata['id']!;
    if(kIsWeb) {
      _streamConts.addAll({newId:data[1]});
    }else{
      _sendPorts.addAll({newId: data[1]});
    }
    _isCancelled.addAll({newId: false});
    _clients.addAll({newId:IOClient()});
    _datas.add(reqdata);
    notifyListeners();
  }

  void removeData(int id){
    if(_clients[id]!=null) {
      _clients[id]!.close();
      _clients.remove(id);
    }
    if(kIsWeb){
      if(_streamConts[id] != null){
        _streamConts[id]!.add(null);
        _streamConts[id]!.close();
        _streamConts.remove(id);
      } else{
        throw Exception('no such request in queue');
      }
    }else {
      if (_sendPorts[id] != null) {
        _sendPorts[id]!.send(null);
        _sendPorts.remove(id);
      } else {
        throw Exception('no such request in queue');
      }
    }
    _isCancelled[id] = true;
     _datas.removeWhere((element) => element['id']==id);

  }
}


void _entryFunction(var meta) async {
  print("entry function started");
  ReceivePort receivePort = ReceivePort();
  meta.send(receivePort.sendPort);

  // As data comes to the network isolate, it is added to a notifier
  receivePort.listen((message) {
    if (message[0] is Map) {
      UnwiredWeb._requestDataHandler.addData(message);
    } else {
      print('id received ' + message.toString());
      UnwiredWeb._requestDataHandler.removeData(message[0]);
    }
  });

  // notifier reacts to arrived data
  UnwiredWeb._requestDataHandler.addListener(() async {
    SendPort childSendPort;
    print("child received");
    int id = UnwiredWeb._requestDataHandler.newId;
    childSendPort = UnwiredWeb._requestDataHandler._sendPorts[id]!;
    var data = UnwiredWeb._requestDataHandler._datas.singleWhere((
        element) => element['id'] == id);
    late CALLTYPE call;
    IOClient client = UnwiredWeb._requestDataHandler._clients[id]!;
    bool? auth;
    Map<String, String>? header;
    Map<String, String>? param;
    Map<String, dynamic>? body;
    late URLRoute route;

    if (data is Map<String, dynamic>) {
      call = data['call']!;
      auth = data['auth'];
      header = data['header'];
      param = data['param'];
      body = data['body'];
      route = data['route']!;
    }

    final Uri uri = Uri.https(route.URL, route.route, param);
    print(uri);
    Map<String, String> headerData = Map.from(
        {HttpHeaders.contentTypeHeader: route.contentType??'application/x-www-form-urlencoded'});
    if (auth ?? false) {
      headerData.addAll(
          Map.from({HttpHeaders.authorizationHeader: data['token']}));
    }
    if (header != null) {
      headerData.addAll(header);
    }

    print("waiting for response");

    try {
      late Http.Response response;
      switch (call) {
        case CALLTYPE.GET:
          response = await client.get(uri, headers: headerData);
          break;
        case CALLTYPE.POST:
          var parsedBody = jsonEncode(body);
          response = await client.post(uri, headers: headerData, body: parsedBody);
          break;
        case CALLTYPE.DEL:
          response = await client.delete(uri, headers: headerData);
          break;
      }
      print(response.body);
      if (!UnwiredWeb._requestDataHandler._isCancelled[id]!) {
        dynamic modelClass;
        dynamic decoded = jsonDecode(response.body);
        print(decoded.toString());
          if (decoded is List) {
            print("Decoded is list");
            modelClass = [];
            for (dynamic m in decoded) {
              modelClass.add(route.getModelClass(m));
            }
          } else {
            print("Deserialize");
            modelClass = route.getModelClass(decoded);
          }
          childSendPort.send(modelClass);
          print("sent " + modelClass.toString());
      }
    } catch (e) {
      print("Error: " + e.toString());
      childSendPort.send(e);
    } finally {
      UnwiredWeb._requestDataHandler.removeData(id);
    }
    UnwiredWeb._requestDataHandler._isCancelled.remove(id);
  });
}


StreamSubscription _webEntryFunction(StreamController streamController) {
  Stream stream = streamController.stream;

  StreamSubscription streamSubscription = stream.listen((message) {
    if (message[0] is Map) {
      UnwiredWeb._requestDataHandler.addData(message);
    } else {
      print('id received ' + message.toString());
      UnwiredWeb._requestDataHandler.removeData(message[0]);
    }
  });

  UnwiredWeb._requestDataHandler.addListener(() async {
    StreamController childStreamController;
    print("child received");
    int id = UnwiredWeb._requestDataHandler.newId;
    childStreamController = UnwiredWeb._requestDataHandler._streamConts[id]!;
    var data = UnwiredWeb._requestDataHandler._datas.singleWhere((
        element) => element['id'] == id);
    late CALLTYPE call;
    IOClient client = UnwiredWeb._requestDataHandler._clients[id]!;
    bool? auth;
    Map<String, String>? header;
    Map<String, String>? param;
    Map<String, dynamic>? body;
    late URLRoute route;

    if (data is Map<String, dynamic>) {
      call = data['call']!;
      auth = data['auth'];
      header = data['header'];
      param = data['param'];
      body = data['body'];
      route = data['route']!;
    }

    final Uri uri = Uri.https(route.URL, route.route, param);
    print(uri);
    Map<String, String> headerData = Map.from(
        {HttpHeaders.contentTypeHeader: route.contentType??'application/x-www-form-urlencoded'});
    if (auth ?? false) {
      headerData.addAll(
          Map.from({HttpHeaders.authorizationHeader: data['token']}));
    }
    if (header != null) {
      headerData.addAll(header);
    }
    print(headerData.runtimeType);
    print("waiting for response");

    try {
      late Http.Response response;
      switch (call) {
        case CALLTYPE.GET:
          response = await client.get(uri, headers: headerData);
          break;
        case CALLTYPE.POST:
          var parsedBody = jsonEncode(body);
          response = await client.post(uri, headers: headerData, body: parsedBody);
          break;
        case CALLTYPE.DEL:
          response = await client.delete(uri, headers: headerData);
          break;
      }
      print(response.body);
      if (!UnwiredWeb._requestDataHandler._isCancelled[id]!) {
        dynamic modelClass;
        dynamic decoded = jsonDecode(response.body);
        print(decoded.toString());
          if (decoded is List) {
            print("Decoded is list");
            modelClass = [];
            for (dynamic m in decoded) {
              modelClass.add(route.getModelClass(m));
            }
          } else {
            print("Deserialize");
            modelClass = route.getModelClass(decoded);
          }
          childStreamController.add(modelClass);
          print("sent " + modelClass.toString());

      }
    } catch (e) {
      print("Error: " + e.toString());
      childStreamController.add(e);
    } finally {
      UnwiredWeb._requestDataHandler.removeData(id);
    }
    UnwiredWeb._requestDataHandler._isCancelled.remove(id);
  });

  return streamSubscription;
}





