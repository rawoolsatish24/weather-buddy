import 'package:http/http.dart' as http;

class APINetwork {
  static Future<String?> fetchURL(Uri uri, {Map<String, String>? headers}) async {
    try {
      final response = await http.get(uri, headers: headers).timeout(const Duration(seconds: 10));
      if(response.statusCode == 200) {
        return response.body;
      }
    } catch (ex) { print(ex.toString()); }
    return null;
  }
}