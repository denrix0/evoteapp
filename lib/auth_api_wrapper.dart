import 'package:http/http.dart' as http;

enum reqUris{
  post
}

extension ReqUrisExtension on reqUris {
  static String apiUrl = 'https://jsonplaceholder.typicode.com/';

  String get uri {
    switch (this) {
      case reqUris.post: return apiUrl+'todos/1';
    }
  }
}

class AuthAPI {
  Future sendApiRequest() async {
    var response = await http.get(Uri.parse(reqUris.post.uri));
    return response.body;
  }
}