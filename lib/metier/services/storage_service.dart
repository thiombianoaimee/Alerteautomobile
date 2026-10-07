import 'package:shared_preferences/shared_preferences.dart';

class StorageService {

  static Future<void> saveToken(String token) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "token",
      token,
    );

  }


  static Future<String?> getToken() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("token");

  }
  static Future<void> saveUserId(String id) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      "userId",
      id,
    );

  }


  static Future<String?> getUserId() async {

    final prefs = await SharedPreferences.getInstance();

    return prefs.getString("userId");

  }
// Supprimer les informations de connexion
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove("token");
    await prefs.remove("userId");
  }

  // ========================================================
  // CACHE GÉNÉRIQUE (pour le mode hors connexion)
  // Stocke n'importe quelle réponse API (déjà en JSON texte)
  // sous une clé donnée, avec la date de sauvegarde.
  // ========================================================

  static Future<void> saveCache(String cle, String jsonBrut) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("cache_$cle", jsonBrut);
    await prefs.setString(
      "cache_${cle}_date",
      DateTime.now().toIso8601String(),
    );
  }

  static Future<String?> getCache(String cle) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("cache_$cle");
  }

  static Future<DateTime?> getCacheDate(String cle) async {
    final prefs = await SharedPreferences.getInstance();
    final dateStr = prefs.getString("cache_${cle}_date");
    if (dateStr == null) return null;
    return DateTime.tryParse(dateStr);
  }

}