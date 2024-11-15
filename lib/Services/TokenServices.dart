import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  Future<Map<String, dynamic>?> getDecodedToken() async {
    try {
      // Retrieve the token from shared preferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('authToken'); // Assuming token is stored with this key

      if (authToken == null) {
        throw Exception('No auth token found in SharedPreferences');
      }

      // Decode the JWT token
      Map<String, dynamic> decodedToken = JwtDecoder.decode(authToken);

      return decodedToken; // Return the entire decoded token
    } catch (e) {
      print('Error decoding token or retrieving from SharedPreferences: $e');
      return null;
    }
  }


  Future<String?> getToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString('authToken');
    } catch (e) {
      print('Error retrieving token from SharedPreferences: $e');
      return null;
    }
  }
}
