abstract class QueueManager<T> {
  final Set<T> _queue = Set<T>();

  bool addToQueue(T element){
    return _queue.add(element);
  }

  bool queueContains(T element) {
    return _queue.contains(element);
  }

  bool removeFromQueue(T element) {
    return _queue.remove(element);
  }

  T createNewQueueObject() {
    throw UnimplementedError();
  }
}

class RequestIdQueueManager extends QueueManager<int> {
  int _counter = 0;

  int _getUnusedId() {
    while (queueContains(_counter)) {
      _counter++;
    }
    return _counter;
  }

  @override
  int createNewQueueObject() {
    int id = _getUnusedId();
    while(!addToQueue(id)) {
      id = _getUnusedId();
    }
    return id;
  }

}