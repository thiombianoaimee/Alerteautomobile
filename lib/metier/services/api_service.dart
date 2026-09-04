import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';
import 'package:flutter/foundation.dart';

class ApiService {

  // Connexion utilisateur
  static Future<Map<String, dynamic>> login(
      String email, String motDePasse) async {

    final response = await http.post(
      Uri.parse(ApiConfig.login),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "motDePasse": motDePasse,
      }),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      debugPrint(data.toString());

      return data;
    }

    else {
      throw Exception(
        "Erreur connexion : ${response.body}",
      );
    }
  }


// Inscription utilisateur
  static Future<Map<String, dynamic>> register(
      Map<String, dynamic> userData) async {

    final response = await http.post(
      Uri.parse(ApiConfig.register),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(userData),
    );

    debugPrint("REPONSE INSCRIPTION : ${response.statusCode}");
    debugPrint("BODY INSCRIPTION : ${response.body}");

    if (response.statusCode == 201 ||
        response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {

      try {
        final data = jsonDecode(response.body);

        throw Exception(
          data['message'] ??
              "Erreur lors de l'inscription",
        );

      } catch (e) {

        // Si la réponse du serveur n'est pas un JSON valide
        if (e is Exception) {
          rethrow;
        }

        throw Exception(
          "Erreur lors de l'inscription",
        );
      }
    }
  }




  // Demander la réinitialisation du mot de passe
  static Future<void> requestPasswordReset(String email) async {
    final response = await http.post(
      Uri.parse(ApiConfig.forgotPassword),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? "Erreur lors de la demande de réinitialisation");
    }
  }

// Réinitialiser le mot de passe avec le token présent dans le lien
  static Future<void> resetPassword(
      String token,
      String nouveauMotDePasse) async {

    final response = await http.post(
      Uri.parse("${ApiConfig.resetPassword}/$token"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "nouveauMotDePasse": nouveauMotDePasse,
      }),
    );

    if (response.statusCode != 200) {
      try {
        final data = jsonDecode(response.body);

        throw Exception(
          data['message'] ??
              "Erreur lors de la réinitialisation du mot de passe",
        );
      } catch (e) {
        throw Exception(
          "Erreur lors de la réinitialisation : ${response.body}",
        );
      }
    }
  }

  //enregistrer un véhicule
  static Future<Map<String, dynamic>> addVehicle(
      Map<String, dynamic> vehicleData,
      String token,
      ) async {

    final response = await http.post(
      Uri.parse(ApiConfig.vehicles),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(vehicleData),
    );

    return jsonDecode(response.body);
  }

  // Récupérer tous les véhicules - Admin
  static Future<List<dynamic>> getVehicles(String token) async {

    final response = await http.get(
      Uri.parse(ApiConfig.vehicles),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("REPONSE VEHICULES ADMIN : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération véhicules : ${response.body}",
      );
    }
  }

  // --- CONFIGURATION DES ALERTES ---

  // Récupérer la configuration des alertes
  static Future<dynamic> getAlertConfigs(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.config),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Erreur récupération config alertes");
    }
  }

  // Mettre à jour la configuration des alertes
  static Future<void> updateAlertConfigs(String token, List<Map<String, dynamic>> regles) async {
    final response = await http.put(
      Uri.parse(ApiConfig.config),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"regles": regles}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Erreur mise à jour config alertes : ${response.body}");
    }
  }

// Liste des véhicules par automobilistes
  static Future<List<dynamic>> getMyVehicles(String token) async {

    final response = await http.get(

      Uri.parse(
        "${ApiConfig.baseUrl}/vehicles/mes-vehicules",
      ),

      headers: {

        "Authorization": "Bearer $token",

        "Content-Type": "application/json",

      },

    );


    if(response.statusCode == 200){

      return jsonDecode(response.body);

    }else{

      throw Exception(
          "Erreur récupération véhicules"
      );

    }

  }
// Récupérer les véhicules d'un automobiliste précis - Admin
  static Future<List<dynamic>> getVehiclesByAutomobiliste(
      String automobilisteId,
      String token,
      ) async {

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/vehicles/automobiliste/$automobilisteId",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint(
      "REPONSE VEHICULES AUTOMOBILISTE : ${response.body}",
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération véhicules : ${response.body}",
      );
    }
  }
  // Ajouter une disponibilité
  static Future<Map<String, dynamic>> addCreneau(
      Map<String, dynamic> creneauData,
      String token) async {

    final response = await http.post(
      Uri.parse(ApiConfig.creneaux),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(creneauData),
    );


    if (response.statusCode == 201 ||
        response.statusCode == 200) {

      final data = jsonDecode(response.body);

      debugPrint(data.toString());

      return data;

    } else {

      throw Exception(
        "Erreur ajout créneau : ${response.body}",
      );
    }
  }

  // Modifier une disponibilité
  static Future<Map<String, dynamic>> updateCreneau(
      String creneauId,
      Map<String, dynamic> creneauData,
      String token) async {

    final response = await http.put(
      Uri.parse("${ApiConfig.creneaux}/$creneauId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(creneauData),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      debugPrint("Disponibilité modifiée : $data");

      return data;
    } else {
      throw Exception(
        "Erreur modification créneau : ${response.body}",
      );
    }
  }

// Récupérer les disponibilités d'un garagiste
  static Future<List<dynamic>> getCreneauxByGaragiste(
      String garagisteId) async {

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.creneaux}/garagiste/$garagisteId",
      ),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {

      final data = jsonDecode(response.body);

      debugPrint("Disponibilités : $data");

      return data;

    } else {

      throw Exception(
        "Erreur récupération disponibilités : ${response.body}",
      );
    }
  }

  // Activer ou désactiver le compte d'un utilisateur
  static Future<Map<String, dynamic>> toggleUserStatus(
      String userId,
      String token,
      ) async {

    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}/users/$userId/toggle-status",
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint("REPONSE ACTIVATION/DESACTIVATION : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur activation/désactivation : ${response.body}",
      );
    }
  }


  // Récupérer la liste des automobilistes
  static Future<List<dynamic>> getAutomobilistes() async {
    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/users/automobilistes"),
    );

    debugPrint("REPONSE AUTOMOBILISTES : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération automobilistes : ${response.body}",
      );
    }
  }

//Liste des garagistes
  static Future<List<dynamic>> getGaragistes() async {

    final response = await http.get(
      Uri.parse(ApiConfig.garages),
    );


    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {

      throw Exception(
        "Erreur récupération garagistes : ${response.body}",
      );

    }



}

// Récupérer les garagistes disponibles pour une date
  static Future<Map<String, dynamic>> getGaragistesDisponibles(
      String date,
      ) async {

    final url =
        "${ApiConfig.baseUrl}/rdv/garagistes-disponibles?date=$date";

    final response = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {

      throw Exception(
        "Erreur récupération garagistes disponibles : ${response.body}",
      );

    }
  }


// Récupérer les créneaux disponibles d'un garagiste
  static Future<List<dynamic>> getCreneauxDisponibles(
      String garagisteId,
      String date,
      ) async {

    final url =
        "${ApiConfig.baseUrl}/rdv/creneaux/$garagisteId?date=$date";

    debugPrint("URL : $url");

    final response = await http.get(Uri.parse(url));

    debugPrint("Status : ${response.statusCode}");
    debugPrint("Réponse : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération créneaux : ${response.body}",
      );
    }
  }
// Créer un rendez-vous
  static Future<Map<String, dynamic>> creerRdv(
      Map<String, dynamic> rdvData,
      String token,
      ) async {

    final response = await http.post(
      Uri.parse(ApiConfig.rdv),

      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },

      body: jsonEncode(rdvData),
    );
    
    if (response.statusCode == 201 ||
        response.statusCode == 200) {

      final data = jsonDecode(response.body);

      debugPrint("RDV CREE AVEC SUCCES : $data");

      return data;

    } else {

      throw Exception(
        "Erreur création rendez-vous : ${response.body}",
      );
    }
  }
// Récupérer les rendez-vous de l'automobiliste connecté
  static Future<List<dynamic>> getMesRendezVous(String token) async {

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/appointments/mes-rendezvous"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );
    debugPrint("REPONSE RDV : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération rendez-vous : ${response.body}",
      );
    }
  }

// Récupérer les demandes de rendez-vous du garagiste connecté
  static Future<List> getDemandesGaragiste(String token) async {

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/appointments/garagiste",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("REPONSE DEMANDES GARAGISTE : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération demandes garagiste : ${response.body}",
      );
    }
  }
// ======================================================
// RÉCUPÉRER LES RDV CONFIRMÉS DU GARAGISTE CONNECTÉ
// ======================================================

  static Future<List<dynamic>> getRendezVousGaragiste(
      String token,
      ) async {
    final response = await http.get(
      Uri.parse("${ApiConfig.rdv}/mes-rendez-vous"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    debugPrint(
      "Réponse RDV garagiste : ${response.statusCode} ${response.body}",
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    if (response.statusCode == 401) {
      throw Exception("Session expirée. Veuillez vous reconnecter.");
    }

    throw Exception(
      "Erreur lors du chargement des rendez-vous : "
          "${response.statusCode}",
    );
  }

// Accepter un rendez-vous
  static Future acceptAppointment(
      String token,
      String rendezVousId,
      ) async {
    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}/appointments/$rendezVousId/accepter",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("REPONSE ACCEPTATION : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur acceptation rendez-vous : ${response.body}",
      );
    }
  }


// Annuler / refuser un rendez-vous
  static Future cancelAppointment(
      String token,
      String rendezVousId,
      ) async {
    final response = await http.put(
      Uri.parse(
        "${ApiConfig.baseUrl}/appointments/$rendezVousId/annuler",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("REPONSE ANNULATION : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur annulation rendez-vous : ${response.body}",
      );
    }
  }


  // Récupérer tous les rendez-vous - Administrateur
  static Future<List<dynamic>> getAllAppointments(String token) async {

    final response = await http.get(
      Uri.parse("${ApiConfig.baseUrl}/appointments/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("REPONSE TOUS LES RDV ADMIN : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération des rendez-vous : ${response.body}",
      );
    }
  }
  // Récupérer les statistiques générales - Administrateur
  static Future<Map<String, dynamic>> getStatistiques(
      String token,
      ) async {

    final response = await http.get(
      Uri.parse(
        "${ApiConfig.baseUrl}/users/statistiques",
      ),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint(
      "REPONSE STATISTIQUES ADMIN : ${response.body}",
    );

    if (response.statusCode == 200) {

      return jsonDecode(response.body);

    } else {

      throw Exception(
        "Erreur récupération statistiques : ${response.body}",
      );

    }
  }


// Modifier les informations du profil
  static Future<Map<String, dynamic>> updateProfile(
      String token,
      Map<String, dynamic> userData,
      ) async {

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/users/profile"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(userData),
    );

    debugPrint("REPONSE MODIFICATION PROFIL : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur modification profil : ${response.body}",
      );
    }
  }

  static Future<Map<String, dynamic>> updateEmail(
      String token,
      String email,
      ) async {

    final response = await http.put(
      Uri.parse("${ApiConfig.baseUrl}/users/profile/email"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "email": email,
      }),
    );

    debugPrint("REPONSE MODIFICATION EMAIL : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur modification email : ${response.body}",
      );
    }
  }

  static Future<void> updatePassword(
      String token,
      String ancienMotDePasse,
      String nouveauMotDePasse,
      ) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}/users/profile/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'ancienMotDePasse': ancienMotDePasse,
        'nouveauMotDePasse': nouveauMotDePasse,
      }),
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);

      throw Exception(
        data['message'] ?? 'Erreur lors de la modification du mot de passe',
      );
    }
  }
  static Future<void> deleteMyAccount(
      String token,
      String motDePasse,
      ) async {
    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}/users/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'motDePasse': motDePasse,
      }),
    );

    if (response.statusCode != 200) {
      String message = 'Erreur lors de la suppression du compte';

      try {
        final data = jsonDecode(response.body);

        if (data['message'] != null) {
          message = data['message'];
        }
      } catch (_) {}

      throw Exception(message);
    }
  }

  // Récupérer les notifications de l'automobiliste connecté
  static Future<List<dynamic>> getNotifications(String token) async {

    final response = await http.get(
      Uri.parse(ApiConfig.notifications),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    debugPrint("REPONSE NOTIFICATIONS : ${response.body}");

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur récupération notifications : ${response.body}",
      );
    }
  }

  // Marquer toutes les notifications comme lues
  static Future<void> markNotificationsAsRead(String token) async {
    final response = await http.patch(
      Uri.parse("${ApiConfig.notifications}/marquer-toutes-lues"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      debugPrint("Erreur lors du marquage des notifications : ${response.body}");
    }
  }

  // Obtenir le nombre de notifications non lues
  static Future<int> getUnreadNotificationsCount(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConfig.notifications}/non-lues/count"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint("REPONSE COUNT BACKEND : $data");

        if (data is int) return data;
        if (data is Map) {
          // On vérifie toutes les clés possibles, y compris "nombre"
          return data['nombre'] ?? data['count'] ?? data['unreadCount'] ?? 0;
        }
      }
      
      // En cas de format inconnu ou erreur, calcul manuel via la liste
      final list = await getNotifications(token);
      return list.where((n) => n['lu'] == false).length;
      
    } catch (e) {
      debugPrint("Erreur API count, calcul via liste : $e");
      try {
        final list = await getNotifications(token);
        return list.where((n) => n['lu'] == false).length;
      } catch (_) {
        return 0;
      }
    }
  }
}
