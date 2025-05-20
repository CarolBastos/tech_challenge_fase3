import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = const FlutterSecureStorage();

const _currentKeyId = 'v1';
const _keyPrefix = 'aes_key_';

Future<encrypt.Key> _getKey(String keyId) async {
  final base64Key = await _secureStorage.read(key: '$_keyPrefix$keyId');
  if (base64Key == null) throw Exception('Chave $keyId não encontrada');
  return encrypt.Key(base64Decode(base64Key));
}

Future<encrypt.Key> _getOrCreateCurrentKey() async {
  final currentKey = await _secureStorage.read(key: '$_keyPrefix$_currentKeyId');

  if (currentKey != null) {
    return encrypt.Key(base64Decode(currentKey));
  } else {
    final key = encrypt.Key.fromSecureRandom(32);
    await _secureStorage.write(
      key: '$_keyPrefix$_currentKeyId',
      value: base64Encode(key.bytes),
    );
    return key;
  }
}

Future<String> encryptText(String plainText) async {
  final key = await _getOrCreateCurrentKey();
  final iv = encrypt.IV.fromSecureRandom(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final encrypted = encrypter.encrypt(plainText, iv: iv);

  return jsonEncode({
    'keyId': _currentKeyId,
    'iv': iv.base64,
    'data': encrypted.base64,
  });
}

Future<String> decryptText(String encryptedText) async {
  final decoded = jsonDecode(encryptedText);
  final keyId = decoded['keyId'];
  final iv = encrypt.IV.fromBase64(decoded['iv']);
  final data = decoded['data'];

  final key = await _getKey(keyId);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  return encrypter.decrypt64(data, iv: iv);
}

