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

    if (response.statusCode == 201 ||
        response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        "Erreur inscription : ${response.body}",
      );
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
  static Future<List<dynamic>> getVehicles(String token) async {

    final response = await http.get(
      Uri.parse(ApiConfig.vehicles),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final data = jsonDecode(response.body);

    return data;
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
      Map<String, dynamic> rdvData) async {

    final response = await http.post(

      Uri.parse(ApiConfig.rdv),

      headers: {
        "Content-Type": "application/json",
      },

      body: jsonEncode(rdvData),

    );


    if (response.statusCode == 201 ||
        response.statusCode == 200) {

      final data = jsonDecode(response.body);

      debugPrint(data.toString());

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
}
