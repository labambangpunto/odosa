import 'package:shared_preferences/shared_preferences.dart';

class ProfileService {
  static const String _keyName = 'profile_name';
  static const String _keyPhotoPath = 'profile_photo_path';

  Future<void> saveProfile(String name, String? photoPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    if (photoPath != null) {
      await prefs.setString(_keyPhotoPath, photoPath);
    }
  }

  Future<Map<String, String?>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? 'Pengguna',
      'photoPath': prefs.getString(_keyPhotoPath),
    };
  }
}
