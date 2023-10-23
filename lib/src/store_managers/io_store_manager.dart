import 'dart:io';

import 'package:store_manager/store_manager.dart';

class RequestStoreManager extends StoreManager<int, HttpClientRequest> {
  void storeHttpRequest({required int requestId, required HttpClientRequest request}) {
    addToStore({requestId: request});
  }

  cancelRequest({required int requestId}) {
    getFromStore(requestId).abort();
    removeFromStore(requestId);
  }

  @override
  Map<int, HttpClientRequest> createNewStoreObject() {
    throw UnsupportedError('Cannot create new request objects using this function');
  }

}