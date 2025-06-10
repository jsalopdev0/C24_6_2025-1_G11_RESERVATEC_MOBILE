import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<void> saveUserSession({
    required int userId,
    required String name,
    required String email,
    required String photo,
    required String token,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("userId", userId);
    await prefs.setString("name", name);
    await prefs.setString("email", email);
    await prefs.setString("photo", photo);
    await prefs.setString("token", token);
  
  }

  static Future<Map<String, String>?> getUserSession() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getInt("userId"); 

  final name = prefs.getString("name");
  final email = prefs.getString("email");
  final photo = prefs.getString("photo");
  final token = prefs.getString("token");

  if (userId != null && name != null && email != null && token != null) {
    return {
      "userId": userId.toString(), 
      "name": name,
      "email": email,
      "photo": photo ?? "",
      "token": token,
    };
  }
  return null;
}


  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt("userId"); 
  }
}
