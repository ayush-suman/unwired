import 'dart:async';

/// This is the base class to store the authentication state and
/// credentials of the application.
///
/// Extend this class to implement your own authentication logic. You can store
/// the [authObject] in any db of your choice, in a [FlutterSecureStorage](https://pub.dev/packages/flutter_secure_storage), or
/// in memory if you don't want to persist it.
abstract class AuthManager<T> {
  const AuthManager();

  T get authObject;

  /// [authenticate] is used to store the [authObject] and update
  /// the [isAuthenticated] state to `true`.
  Future authenticate(T authObject);

  /// [unauthenticate] is used to delete the [authObject] and update the
  /// [isAuthenticated] state to `false`.
  Future unauthenticate();

  /// [isAuthenticated] is used to check the authentication state of the app.
  /// Generally, this would check the value of [authObject] to return the state
  /// of authentication.
  bool get isAuthenticated;

  /// Returns [String] type [authObject] in a format that can be used in the
  /// `Authorization` header of a request.
  String get parsedAuthObject;

  /// [synchronize] is used to ensure that the [authObject] is correctly synced.
  /// Call and await this once in the app lifetime to ensure correct value
  /// from [isAuthenticated] and [authObject]
  Future synchronize();
}
