import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:evoteapp/components/structures.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

class AuthAPI {
  static late Map baseUri;
  static late final http.Client client;
  final Logger log = Logger('API Logger');

  AuthAPI() {
    client = http.Client();
  }

  void setBaseUri(
      {String scheme = 'http', String host = '127.0.0.1', int port = 5000}) {
    baseUri = {'scheme': scheme, 'host': host, 'port': port};
  }

  Uri _getUrl(String uriLocation) => Uri(
      scheme: baseUri['scheme'],
      host: baseUri['host'],
      port: baseUri['port'],
      path: uriLocation);

  Future _sendApiRequest(String _location, reqMethod _method,
      {Map<String, String> body = const {},
      Map<String, String> headers = const {
        'Content-Type': 'application/json'
      }}) async {
    AuthResponse _response = AuthResponse(reqStatus.none, resType.none, {});

    Duration _timeout = const Duration(seconds: 10);

    http.Response _httpResponse;
    try {
      if (_method == reqMethod.get) {
        _httpResponse = await client.get(_getUrl(_location)).timeout(_timeout);
      } else {
        _httpResponse = await client
            .post(_getUrl(_location), body: json.encode(body), headers: headers)
            .timeout(_timeout);
      }

      _response.content = json.decode(_httpResponse.body);
      _response.status = reqStatus.success;
      _response.type = _response.content.containsKey("error_type")
          ? resType.error
          : resType.valid;
    } on http.ClientException catch (_) {
      log.warning('HttpRequest Failed');
      _response.status = reqStatus.fail;
    } on TimeoutException {
      log.warning('HttpRequest Timed out');
      _response.status = reqStatus.fail;
    }

    return _response;
  }

  Future checkApiAlive() async {
    try {
      await _sendApiRequest('/', reqMethod.get);
      return reqStatus.success;
    } on Exception {
      return reqStatus.fail;
    }
  }

  Future getVoteForm() async {
    AuthResponse _response = await _sendApiRequest('/vote_form', reqMethod.get);

    return _response;
  }

  Future<AuthResponse> sendLoginRequest(String _id, String _pin) async {
    Map<String, String> _body = {'id': _id, 'pin': _pin};

    AuthResponse _response =
        await _sendApiRequest('/login', reqMethod.post, body: _body);

    return _response;
  }

  Future<AuthResponse> sendAuthRequest(String _type, String _content,
      String _key, String _iv, String _authHeader) async {
    Map<String, String> _body = {
      'auth_type': _type,
      'auth_content': _content,
      'enc_key': _key,
      'iv': _iv
    };

    Map<String, String> _headers = {
      'Content-Type': 'application/json',
      'Authorization': _authHeader
    };

    AuthResponse _response = await _sendApiRequest(
        '/auth_verify', reqMethod.post,
        body: _body, headers: _headers);

    return _response;
  }

  Future<AuthResponse> sendSubmitRequest(String _masterToken,
      String _formOption, String _key, String _iv, String _authHeader) async {
    Map<String, String> _body = {
      "master_token": _masterToken,
      "form_option": _formOption,
      "enc_key": _key,
      "iv": _iv
    };

    Map<String, String> _headers = {
      'Content-Type': 'application/json',
      'Authorization': _authHeader
    };

    AuthResponse _response = await _sendApiRequest('/submit', reqMethod.post,
        body: _body, headers: _headers);

    return _response;
  }
}
