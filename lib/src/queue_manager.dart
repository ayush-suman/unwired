abstract class QueueManager<T> {
  final Set<T> _queue = Set<T>();

  bool addToQueue(T element){
    return _queue.add(element);
  }

  bool queueContains(bool Function(T) filter) {
    final items = _queue.where(filter);
    return items.isNotEmpty;
  }

  bool removeFromQueue(T element) {
    return _queue.remove(element);
  }

  void removeFromQueueIf(bool Function(T) filter) {
    _queue.removeWhere(filter);
  }

  T createNewQueueObject();
}

class RequestIdQueueManager extends QueueManager<int> {
  int _counter = 0;

  int _getUnusedId() {
    while (queueContains((id) => id == _counter)) {
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
