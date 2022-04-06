enum reqMethod { post, get }
enum reqStatus { none, success, fail }

class AuthResponse {
  reqStatus status;
  Map content;

  AuthResponse(this.status, this.content);
}
