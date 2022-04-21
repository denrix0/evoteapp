import 'dart:async';

import 'package:evoteapp/crypto_functions.dart';
import 'package:evoteapp/structures.dart';
import 'auth_api_wrapper.dart';

class AuthManager {
  final CryptoFunctions crypt = CryptoFunctions();

  static final AuthManager _singleton = AuthManager._internal();

  factory AuthManager() {
    return _singleton;
  }

  AuthManager._internal();

  static AuthAPI? authApi;
  String? _jwt;
  String? _pubKey;

  static Map<String, String> tokens = {};
  static Map checkList = {"uid": false, "totp1": false, "totp2": false};

  void init(String _ip, int port) {
    authApi ??= AuthAPI();
    authApi?.setBaseUri(scheme: 'https', host: _ip, port: port);
  }

  Future<Map?> fetchVoteForm() async {
    AuthResponse? _response = await authApi?.getVoteForm();

    if (_response?.status == reqStatus.success) {
      return _response?.content;
    }
    return null;
  }

  Future<AuthResponse?> getPinAuth(String _id, String _pin) async {
    AuthResponse? _response = await authApi?.sendLoginRequest(_id, _pin);

    if (_response?.status == reqStatus.success) {
      if (_response?.type == resType.valid) {
        _jwt = _response?.content['jwt'];
        _pubKey = _response?.content['pub_key'];
      }
    }

    return _response;
  }

  Future<AuthResponse?> getAuth(String _content, String _type) async {
    AuthResponse? _response = AuthResponse(reqStatus.none, resType.none, {});

    if (_jwt != null && _pubKey != null) {
      Map keyIv = crypt.generateKeyIv();

      String content = crypt.aesEncrypt(_content, keyIv['key'], keyIv['iv']);

      _response = await authApi?.sendAuthRequest(
          _type,
          content,
          crypt.rsaEncrypt(_pubKey!, keyIv['key'].base16),
          crypt.rsaEncrypt(_pubKey!, keyIv['iv'].base16),
          _jwt!);

      if (_response?.status == reqStatus.success) {
        if (_response?.type == resType.valid) {
          tokens[_type] = crypt.aesDecrypt(
              _response?.content['token'], keyIv['key'], keyIv['iv']);
          checkList[_type] = true;
        }
      }
    }

    return _response;
  }

  Future<AuthResponse?> sendVote(String _masterToken, _option) async {
    AuthResponse? _response = AuthResponse(reqStatus.none, resType.none, {});

    if (_jwt != null && _pubKey != null) {
      Map keyIv = crypt.generateKeyIv();

      String token = crypt.aesEncrypt(_masterToken, keyIv['key'], keyIv['iv']);
      String option = crypt.aesEncrypt(_option, keyIv['key'], keyIv['iv']);

      for (var item in ['key', 'iv']) {
        keyIv[item] = crypt.rsaEncrypt(_pubKey!, keyIv[item].base16);
      }

      _response = await authApi?.sendSubmitRequest(
          token, option, keyIv['key'], keyIv['iv'], _jwt!);
    }

    return _response;
  }
}
