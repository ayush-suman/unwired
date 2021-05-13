
/// Extend a companion class of every model DTO class with this class and override fromMap to return Model Class
abstract class JSONModelConstructor<T>{

  T fromMap(Map<String, dynamic> data);
}

