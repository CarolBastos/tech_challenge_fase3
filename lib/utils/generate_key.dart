import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = const FlutterSecureStorage();
const _aesKeyStorageKey = 'aes_key';

Future<encrypt.Key> _getOrCreateAESKey() async {
  String? base64Key = await _secureStorage.read(key: _aesKeyStorageKey);

  if (base64Key == null) {
    final key = encrypt.Key.fromSecureRandom(32); // AES 256
    base64Key = base64Encode(key.bytes);
    await _secureStorage.write(key: _aesKeyStorageKey, value: base64Key);
    return key;
  }

  final keyBytes = base64Decode(base64Key);
  return encrypt.Key(keyBytes);
}

Future<String> encryptText(String plainText) async {
  final key = await _getOrCreateAESKey();
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);
  return encrypted.base64;
}

Future<String> decryptText(String encryptedText) async {
  final key = await _getOrCreateAESKey();
  final iv = encrypt.IV.fromLength(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final decrypted = encrypter.decrypt64(encryptedText, iv: iv);
  return decrypted;
}

