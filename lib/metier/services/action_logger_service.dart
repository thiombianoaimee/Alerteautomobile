import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';

class ActionLoggerService {
  static final String _filePath = 'passe.json';

  static Future<void> logAction(UserModel user, String actionDescription) async {
    try {
      final file = File(_filePath);
      Map<String, dynamic> data = {};

      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          try {
            data = json.decode(content);
          } catch (e) {
            data = {};
          }
        }
      }

      // Initialiser la liste des actions si elle n'existe pas
      if (!data.containsKey('actions')) {
        data['actions'] = [];
      }

      // Ajouter la nouvelle action
      final logEntry = {
        'userId': user.id,
        'nom': user.nom,
        'role': user.role,
        'action': actionDescription,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      data['actions'].add(logEntry);

      // Écrire dans le fichier (indenté)
      final encoder = JsonEncoder.withIndent('  ');
      await file.writeAsString(encoder.convert(data));
      
    } catch (e) {
      print("Erreur lors de l'enregistrement de l'action : $e");
    }
  }
}
