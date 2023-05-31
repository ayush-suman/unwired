import 'dart:html';

import 'package:store_manager/store_manager.dart';

class RequestStoreManager<K> extends StoreManager<K, HttpRequest> {
  void storeHttpRequest({required K requestId, required HttpRequest request}) {
    addToStore({requestId: request});
  }

  cancelRequest({required K requestId}) {
    getFromStore(requestId).abort();
    removeFromStore(requestId);
  }

  @override
  Map<K, HttpRequest> createNewStoreObject() {
    throw UnsupportedError('Cannot create new request objects using this function');
  }

}