import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:komodo_defi_local_auth/src/auth/storage/secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SecureLocalStorage fallback', () {
    setUp(() {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      // In tests the flutter_secure_storage platform channel is not
      // registered, so keychain operations throw MissingPluginException and
      // the storage should fall back to SharedPreferences.
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
        (MethodCall call) async => throw MissingPluginException(),
      );
    });

    test('write/read/delete roundtrip uses prefs fallback', () async {
      final storage = SecureLocalStorage();

      await storage.write(key: 'test_key', value: 'test_value');
      expect(await storage.read(key: 'test_key'), 'test_value');

      await storage.delete(key: 'test_key');
      expect(await storage.read(key: 'test_key'), isNull);
    });

    test('last active wallet name roundtrip and clear', () async {
      final storage = SecureLocalStorage();

      await storage.saveLastActiveWalletName('my_wallet');
      expect(await storage.getLastActiveWalletName(), 'my_wallet');

      await storage.clearSecureStorage();
      expect(await storage.getLastActiveWalletName(), isNull);
    });
  });
}
