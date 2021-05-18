import 'package:flutter_test/flutter_test.dart';
import 'package:unwired/json_model.dart';
import 'package:unwired/response.dart';
import 'package:unwired/unwired.dart';
import 'package:unwired/url_route.dart';
import 'package:unwired/calltype.dart';


class TestURLRoute<T> extends URLRoute<T>{
  TestURLRoute({required String route, required JSONModelConstructor<T> jsonModelConstructor, required CALLTYPE calltype, String? contentType}) : super("xxx", route, calltype, jsonModelConstructor, contentType: contentType);
}

class ResponseClass {
  final success;

  ResponseClass(this.success);

  static ResponseClass fromJSON(Map<String, dynamic> data){
    return ResponseClass(data["success"]);
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
    final testUrlRoute = TestURLRoute<ResponseClass>(route: 'patient/requestOTP', calltype: CALLTYPE.POST, jsonModelConstructor: TestConstructor());
    Response<ResponseClass, ResponseClass> response = await spider.request<ResponseClass, ResponseClass>(route: testUrlRoute, body: {"phone": "7762961997"});
    try {
      var value = await response.response;
      print(value.success);
    }catch(e){
      print("Exception");
    }
  });
}
