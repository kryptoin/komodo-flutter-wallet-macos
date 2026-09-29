// lib/src/auth/secure_storage.dart

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:komodo_defi_types/komodo_defi_type_utils.dart';
import 'package:komodo_defi_types/komodo_defi_types.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Storage {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

class SecureLocalStorage {
  factory SecureLocalStorage() => _instance;
  SecureLocalStorage._();
  static final SecureLocalStorage _instance = SecureLocalStorage._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _userPrefix = 'user_';
  static const String _lastActiveWalletNameKey = 'lastActiveWalletName';
  static const String _prefsFallbackPrefix = 'secure_local_storage_';

  SharedPreferences? _prefsFallback;

  /// Tri-state cache: null = keychain not probed yet, true = keychain usable,
  /// false = fall back to SharedPreferences.
  bool? _keychainAvailable;

  /// Save user data
  Future<void> saveUser(KdfUser user) async {
    final jsonString = user.toJson().toJsonString();
    await write(key: '$_userPrefix${user.walletId.name}', value: jsonString);
  }

  /// Get user data
  Future<KdfUser?> getUser(String walletName) async {
    final jsonString = await read(key: '$_userPrefix$walletName');
    if (jsonString == null) return null;
    return KdfUser.fromJson(jsonFromString(jsonString));
  }

  /// Delete user data
  Future<void> deleteUser(String walletName) async {
    await delete(key: '$_userPrefix$walletName');
  }

  /// Save the last active wallet name
  Future<void> saveLastActiveWalletName(String? walletName) async {
    if (walletName == null) {
      await delete(key: _lastActiveWalletNameKey);
    } else {
      await write(key: _lastActiveWalletNameKey, value: walletName);
    }
  }

  /// Get the last active wallet name
  Future<String?> getLastActiveWalletName() async {
    return read(key: _lastActiveWalletNameKey);
  }

  /// Clears all secure storage
  Future<void> clearSecureStorage() async {
    if (await _useKeychain()) {
      await _storage.deleteAll();
      return;
    }
    final prefs = await _getPrefsFallback();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith(_prefsFallbackPrefix))
        .toList();
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  Future<void> write({required String key, required String value}) async {
    if (await _useKeychain()) {
      await _storage.write(key: key, value: value);
      return;
    }
    final prefs = await _getPrefsFallback();
    await prefs.setString('$_prefsFallbackPrefix$key', value);
  }

  Future<String?> read({required String key}) async {
    if (await _useKeychain()) {
      return _storage.read(key: key);
    }
    final prefs = await _getPrefsFallback();
    return prefs.getString('$_prefsFallbackPrefix$key');
  }

  Future<void> delete({required String key}) async {
    if (await _useKeychain()) {
      await _storage.delete(key: key);
      return;
    }
    final prefs = await _getPrefsFallback();
    await prefs.remove('$_prefsFallbackPrefix$key');
  }

  /// Probes the keychain once and caches the result. Ad-hoc signed macOS
  /// builds (local development, no Apple signing identity) cannot claim the
  /// restricted keychain-access-groups entitlement, so keychain writes fail
  /// with errSecMissingEntitlement (-34018) and would otherwise break wallet
  /// registration. Only non-secret wallet metadata is stored here (secrets
  /// live in KDF's own encrypted database), so falling back to
  /// SharedPreferences is acceptable for local development builds, mirroring
  /// the fallback in SecureRpcPasswordMixin.
  Future<bool> _useKeychain() async {
    if (_keychainAvailable != null) return _keychainAvailable!;

    try {
      const probeKey = '$_userPrefix\_probe';
      await _storage.write(key: probeKey, value: 'probe');
      await _storage.delete(key: probeKey);
      _keychainAvailable = true;
    } catch (e) {
      if (!kReleaseMode || Platform.isMacOS) {
        _keychainAvailable = false;
        debugPrint(
          'WARNING: secure storage unavailable ($e). '
          'Falling back to SharedPreferences (local dev only).',
        );
      } else {
        rethrow;
      }
    }
    return _keychainAvailable!;
  }

  Future<SharedPreferences> _getPrefsFallback() async =>
      _prefsFallback ??= await SharedPreferences.getInstance();
}
