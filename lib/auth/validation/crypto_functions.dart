import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:pointycastle/asymmetric/api.dart';

class CryptoFunctions {
  String generateMasterToken(String uid, String totp1, String totp2) {
    String _tokenString = uid + "." + totp1 + "." + totp2;
    var digest = sha256.convert(utf8.encode(_tokenString));
    return digest.toString();
  }

  String rsaEncrypt(String pubPem, String _encryptedToBe) {
    final publicKey = RSAKeyParser().parse(pubPem);

    final encryptor = Encrypter(RSA(
        publicKey: publicKey as RSAPublicKey,
        privateKey: null,
        encoding: RSAEncoding.OAEP,
        digest: RSADigest.SHA256));

    return encryptor.encrypt(_encryptedToBe).base16;
  }

  Map generateKeyIv() {
    final key = Key.fromSecureRandom(32);
    final iv = IV.fromSecureRandom(16);

    return {'key': key, 'iv': iv};
  }

  String aesEncrypt(String _encryptedToBe, Key key, IV iv) {
    final encryptor = Encrypter(AES(key, mode: AESMode.cbc));

    final encrypted = encryptor.encrypt(_encryptedToBe, iv: iv);

    return encrypted.base16;
  }

  String aesDecrypt(String _decryptedToBe, Key key, IV iv) {
    final encryptor = Encrypter(AES(key, mode: AESMode.cbc));
    final decrypted =
        encryptor.decrypt(Encrypted.fromBase16(_decryptedToBe), iv: iv);

    return decrypted;
  }
}
