import 'dart:async';

import 'package:evoteapp/auth/validation/crypto_functions.dart';
import 'package:evoteapp/components/structures.dart';
import 'package:flutter/material.dart';

import 'package:evoteapp/auth/auth_api_wrapper.dart';
import 'package:evoteapp/auth/validation/field_validations.dart';

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
    init('192.168.1.33', 5000);//TODO: reset
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

  void authLogin(context, String server, String id, String pin,
      MaterialPageRoute pageRoute) async {
    List _errorList = [];

    ValidationResult _sever = FieldValidations.validateIpAddress(server);
    ValidationResult _cred = FieldValidations.validateIDAndPIN(id, pin);

    _errorList.addAll(_sever.errors);
    _errorList.addAll(_cred.errors);

    if (_errorList.isEmpty) {
      init(_sever.data['serverIP'], _sever.data['serverPort']);
      AuthResponse? _response =
          await getPinAuth(_cred.data['id'], _cred.data['pin']);

      if (_response?.status == reqStatus.success) {
        if (_response?.type == resType.valid) {
          Navigator.pushAndRemoveUntil(context, pageRoute, (route) => false);
        } else if (_response?.type == resType.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_response?.content['message']),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Request failed"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_errorList.first),
      ));
    }
  }

  void verifyAuth(
      BuildContext context, state, String text, authType type) async {
    Map _params = {'type': type.typeString};
    ValidationResult _validResult;

    switch (type) {
      case authType.tOtp1:
      case authType.tOtp2:
        _params['content'] = 'otp';
        _validResult = FieldValidations.validateUID(text);
        break;
      case authType.uniqueID:
        _params['content'] = 'uid';
        _validResult = FieldValidations.validateUID(text);
        break;
    }

    if (_validResult.errors.isEmpty) {
      AuthResponse? _response =
          await getAuth(_validResult.data['uid'], _params['type']);

      if (_response?.status == reqStatus.success) {
        if (_response?.type == resType.valid) {
          state(() {});
        } else if (_response?.type == resType.error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(_response?.content['message']),
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Request Failed"),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_validResult.errors.first),
      ));
    }
  }

  Future<Map> castVote(String _masterToken, _selectedChoice) async {
    Map _pageContent = {'title': '', 'message': '', 'error': null};

    final AuthResponse? _response =
        await sendVote(_masterToken, _selectedChoice);

    if (_response?.status == reqStatus.success) {
      if (_response?.type == resType.valid) {
          _pageContent['title'] = 'Vote Cast';
          _pageContent['message'] = 'Vote has been successfully cast. You can close the app now.';
      } else if (_response?.type == resType.error) {
        _pageContent['title'] = 'Error Casting Vote';
        _pageContent['message'] = _response?.content['message'];
      } else {
        _pageContent['error'] = "Could not cast vote: ???";
      }
    } else {
      _pageContent['error'] = "Could not cast vote: Request failed.";
    }

    return _pageContent;
  }
}
