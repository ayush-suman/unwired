import 'package:queue_manager/queue_manager.dart';

/// A [QueueManager] to store request ids. Used by [RequestHandler] to keep a
/// track of ongoing requests.
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
    while (!addToQueue(id)) {
      id = _getUnusedId();
    }
    return id;
  }
}