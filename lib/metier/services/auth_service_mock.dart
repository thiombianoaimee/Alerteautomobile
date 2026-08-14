
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/user_model.dart';
import 'package:flutter/foundation.dart';

class AuthServiceMock {
Future<UserModel?> login(String email, String password) async {
try {
// Pour simuler un temps de réseau
await Future.delayed(const Duration(seconds: 1));

final String response =
await rootBundle.loadString('assets/data/users_mock.json');

final data = json.decode(response);
final List<dynamic> usersJson = data['users'];

for (var userJson in usersJson) {
final UserModel user = UserModel.fromJson(userJson);

if (user.email == email && userJson['password'] == password) {
return user; // Succès
}
}

return null; // Échec : identifiants incorrects
} catch (e) {
debugPrint("Erreur de chargement du mock: $e");
return null;
}
}
}

