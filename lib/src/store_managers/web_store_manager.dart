import 'dart:html';

import 'package:store_manager/store_manager.dart';

class RequestStoreManager extends StoreManager<int, HttpRequest> {
  RequestStoreManager() : super();

  void storeHttpRequest({required int requestId, required HttpRequest request}) {
    addToStore({requestId: request});
  }

  cancelRequest({required int requestId}) {
    getFromStore(requestId).abort();
    removeFromStore(requestId);
  }

  @override
  Map<int, HttpRequest> createNewStoreObject() {
    throw UnsupportedError('Cannot create new request objects using this function');
  }

}