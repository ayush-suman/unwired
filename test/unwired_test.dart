import 'package:flutter_test/flutter_test.dart';
import 'package:unwired/json_model.dart';
import 'package:unwired/response.dart';
import 'package:unwired/unwired.dart';
import 'package:unwired/url_route.dart';
import 'package:unwired/calltype.dart';


class TestURLRoute<T> extends URLRoute<T>{
  TestURLRoute(String route, JSONModelConstructor<T> jsonModelConstructor) : super("api.github.com", route, jsonModelConstructor);
}

class ResponseClass {
  final id;
  final name;
  ResponseClass(this.id, this.name);

  static ResponseClass fromJSON(Map<String, dynamic> data){
    return ResponseClass(data["id"], data["name"]);
  }
}

class TestConstructor extends JSONModelConstructor<ResponseClass>{

  @override
  ResponseClass fromMap(Map<String, dynamic> data) {
    return ResponseClass.fromJSON(data);
  }
}

void main() {
  test('Simple Test using Github API', () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final spider = Unwired.getInstance();
    await spider.initialiseNetwork();
    final testUrlRoute =TestURLRoute<ResponseClass>("/orgs/DSCBits/repos",  TestConstructor());
    Response<List<ResponseClass>, ResponseClass> response = await spider.request<List<ResponseClass>, ResponseClass>(route: testUrlRoute, call: CALLTYPE.GET );
    try {
      var value = await response.response;
      print(value[0].id);
    }catch(e){
      print("Exception");
    }
  });
}
