enum reqMethod { post, get }
enum reqStatus { none, success, fail }
enum authType { tOtp1, tOtp2, uniqueID }

class AuthResponse {
  reqStatus status;
  Map content;

  AuthResponse(this.status, this.content);
}
