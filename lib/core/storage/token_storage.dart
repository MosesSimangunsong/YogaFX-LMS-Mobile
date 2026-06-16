import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract interface class TokenStorage {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
}

class SecureTokenStorage implements TokenStorage {
  const SecureTokenStorage();

  static const _tokenKey = 'auth_token';
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }

  @override
  Future<String?> readToken() {
    return _storage.read(key: _tokenKey);
  }

  @override
  Future<void> writeToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }
}
