abstract class BaseStorage {
  Future<bool> write(String key, dynamic data);
  Future<dynamic> read(String key);
  Future<bool> delete(String key);
}
