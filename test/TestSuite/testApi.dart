import 'package:evoteapp/auth_api_wrapper.dart';
import 'package:evoteapp/structures.dart';
import 'package:test/test.dart';

var api = AuthAPI(host: "192.168.1.34");

void apiAliveTest() {
  test('Check Api Alive', () async {
    reqStatus _status = await api.checkApiAlive();
    expect(_status, equals(reqStatus.success));
  });
}

void apiFormFetchTest() async {
  test('Testing Vote Form Fetch', () async {
    Map response = await api.getVoteForm();
    expect(response['options'], contains('Option 1'));
  });
}

void apiSendLoginRequest() async {
  AuthResponse response;

  group('Login Tests: ', () {
    test('Failed Login Test', () async {
      response = await api.sendLoginRequest("0000", "0000");
      expect(response.status, equals(reqStatus.success));
      expect(response.content['error_type'], equals('auth_failed'));
    });

    test("Passed Login Test", () async {
      response = await api.sendLoginRequest("1234", "0000");
      expect(response.status, equals(reqStatus.success));
      expect(response.content['enc_key'], equals('big key'));
    });
  });
}

void apiSendAuthRequests() async {
  AuthResponse response;
  test('Testing Auth Endpoint', () async {
    response = await api.sendAuthRequest(
        'lotta types', 'wacky key', 'this is wack jwt');
    expect(response.status, equals(reqStatus.success));
    expect(response.content['token'], equals('big token'));
  });
}

void apiSendSubmitRequest() async {
  AuthResponse response;
  test('Testing Submit Endpoint', () async {
    response = await api.sendSubmitRequest(
        'wack token', 'some option', 'this is wack jwt');
    expect(response.status, equals(reqStatus.success));
    expect(response.content['vote_status'], equals('success'));
  });
}

void runTests() {
  apiAliveTest();
  apiFormFetchTest();
  apiSendLoginRequest();
  apiSendAuthRequests();
  apiSendSubmitRequest();
}
