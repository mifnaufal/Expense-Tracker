import 'package:web/web.dart' as web;

Future<String?> webStorageRead(String key) async {
  try {
    final storage = web.window.localStorage;
    return storage.getItem(key);
  } catch (e) {
    throw Exception('Local storage read failed: $e');
  }
}

Future<void> webStorageWrite(String key, String value) async {
  try {
    final storage = web.window.localStorage;
    storage.setItem(key, value);
  } catch (e) {
    throw Exception('Local storage write failed: $e');
  }
}
