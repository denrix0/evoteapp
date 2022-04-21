enum reqMethod { post, get }
enum reqStatus { none, success, fail }
enum resType { none, valid, error }
enum authType { tOtp1, tOtp2, uniqueID }

class AuthResponse {
  reqStatus status;
  resType type;
  Map content;

  AuthResponse(this.status, this.type, this.content);
}
