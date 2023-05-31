import 'dart:io';

import 'package:store_manager/store_manager.dart';

class RequestStoreManager<K> extends StoreManager<K, HttpClientRequest> {
  void storeHttpRequest({required K requestId, required HttpClientRequest request}) {
    addToStore({requestId: request});
  }

  cancelRequest({required K requestId}) {
    getFromStore(requestId).abort();
    removeFromStore(requestId);
  }

  @override
  Map<K, HttpClientRequest> createNewStoreObject() {
    throw UnsupportedError('Cannot create new request objects using this function');
  }

}