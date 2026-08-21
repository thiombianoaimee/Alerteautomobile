import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_auto_screen.dart';

class SuiviAutomobilisteScreen extends StatefulWidget {
  final UserModel user;

  const SuiviAutomobilisteScreen({
    super.key,
    required this.user,
  });

  @override
  State<SuiviAutomobilisteScreen> createState() =>
      _SuiviAutomobilisteScreenState();
}

class _SuiviAutomobilisteScreenState
    extends State<SuiviAutomobilisteScreen> {
  List vehicules = [];
  List rendezVous = [];

  bool afficherVehicules = false;
  bool afficherRendezVous = false;

  // ============================================================
  // FORMATAGE DE LA DATE
  // ============================================================

  String formaterDate(String? date) {
    if (date == null || date.isEmpty) {
      return "Inconnue";
    }

    try {
      final dateTime = DateTime.parse(date);

      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year}";
    } catch (e) {
      return "Inconnue";
    }
  }

  // ============================================================
  // CHARGER LES VEHICULES
  // ============================================================

  Future<void> chargerVehicules() async {
    final savedToken = await StorageService.getToken();

    if (savedToken == null) {
      return;
    }

    try {
      final liste = await ApiService.getMyVehicles(savedToken);

      if (!mounted) return;

      setState(() {
        vehicules = liste;
      });
    } catch (e) {
      debugPrint("Erreur chargement véhicules : $e");
    }
  }

  // ============================================================
  // CHARGER LES RENDEZ-VOUS
  // ============================================================

  Future<void> chargerRendezVous() async {
    final savedToken = await StorageService.getToken();

    if (savedToken == null) {
      return;
    }

    try {
      final liste = await ApiService.getMesRendezVous(savedToken);

      debugPrint("Rendez-vous reçus : $liste");

      if (!mounted) return;

      setState(() {
        rendezVous = liste;
      });
    } catch (e) {
      debugPrint("Erreur chargement rendez-vous : $e");
    }
  }

  // ============================================================
  // RECUPERER LE VEHICULE D'UN RENDEZ-VOUS
  // ============================================================

  Map<String, dynamic>? recupererVehicule(dynamic rdv) {
    final vehiculeRdv = rdv["vehicule"];

    // Si le backend renvoie directement l'objet véhicule
    if (vehiculeRdv is Map) {
      return Map<String, dynamic>.from(vehiculeRdv);
    }

    // Si le backend renvoie seulement l'ID du véhicule
    if (vehiculeRdv != null) {
      for (final vehicule in vehicules) {
        if (vehicule["_id"].toString() ==
            vehiculeRdv.toString()) {
          return Map<String, dynamic>.from(vehicule);
        }
      }
    }

    return null;
  }

  // ============================================================
  // FORMATAGE DU STATUT
  // ============================================================

  String afficherStatut(String? statut) {
    switch (statut) {
      case "confirme":
        return "Confirmé";

      case "annule":
        return "Annulé";

      case "en_attente":
        return "En attente";

      default:
        return statut ?? "Inconnu";
    }
  }

  Color couleurStatut(String? statut) {
    switch (statut) {
      case "confirme":
        return Colors.green;

      case "annule":
        return Colors.red;

      default:
        return Colors.orange;
    }
  }

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    chargerVehicules();
    chargerRendezVous();
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mon espace de suivi automobile",
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/notifications',
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilAutoScreen(
                    user: widget.user,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SafeArea(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ==================================================
              // SECTION MES VEHICULES
              // ==================================================

              Row(
                children: [
                  const Icon(
                    Icons.directions_car,
                    color: Colors.blue,
                    size: 30,
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      "Mes véhicules",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ==================================================
              // BOUTON VEHICULES
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      afficherVehicules = !afficherVehicules;
                    });
                  },

                  icon: Icon(
                    afficherVehicules
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),

                  label: Text(
                    afficherVehicules
                        ? "Masquer mes véhicules"
                        : "Voir mes véhicules",
                  ),
                ),
              ),

              // ==================================================
              // LISTE DES VEHICULES
              // ==================================================

              if (afficherVehicules) ...[
                const SizedBox(height: 20),

                if (vehicules.isEmpty)
                  const Text(
                    "Aucun véhicule enregistré.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: vehicules.map((vehicule) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 20,
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              "${vehicule["marque"] ?? ""} "
                                  "${vehicule["modele"] ?? ""}",
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Immatriculation : "
                                  "${vehicule["immatriculation"] ?? ""}",
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Date de la dernière visite technique : "
                                  "${formaterDate(
                                vehicule[
                                "dateDerniereVisiteTechnique"
                                ]?.toString(),
                              )}",
                            ),

                            const Divider(
                              height: 25,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],

              const SizedBox(height: 30),

              // ==================================================
              // SECTION MES RENDEZ-VOUS
              // ==================================================

              Row(
                children: [
                  const Icon(
                    Icons.calendar_month,
                    color: Colors.green,
                    size: 30,
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      "Mes rendez-vous",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // ==================================================
              // BOUTON RENDEZ-VOUS
              // ==================================================

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      afficherRendezVous =
                      !afficherRendezVous;
                    });
                  },

                  icon: Icon(
                    afficherRendezVous
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),

                  label: Text(
                    afficherRendezVous
                        ? "Masquer mes rendez-vous"
                        : "Voir mes rendez-vous",
                  ),
                ),
              ),

              // ==================================================
              // LISTE DES RENDEZ-VOUS
              // ==================================================

              if (afficherRendezVous) ...[
                const SizedBox(height: 20),

                if (rendezVous.isEmpty)
                  const Text(
                    "Aucun rendez-vous disponible.",
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount: rendezVous.length,

                    itemBuilder: (context, index) {
                      final rdv = rendezVous[index];

                      // ------------------------------------------
                      // DATE
                      // ------------------------------------------

                      DateTime date;

                      try {
                        date = DateTime.parse(
                          rdv["dateRdv"].toString(),
                        );
                      } catch (e) {
                        date = DateTime.now();
                      }

                      // ------------------------------------------
                      // GARAGISTE
                      // ------------------------------------------

                      final garagiste = rdv["garagiste"];

                      String nomGaragiste = "Inconnu";
                      String telephoneGaragiste =
                          "Non renseigné";
                      String adresseGaragiste =
                          "Non renseignée";

                      if (garagiste is Map) {
                        nomGaragiste =
                            garagiste["nom"]?.toString() ??
                                "Inconnu";

                        telephoneGaragiste =
                            garagiste["telephone"]?.toString() ??
                                "Non renseigné";

                        adresseGaragiste =
                            garagiste["adresse"]?.toString() ??
                                "Non renseignée";
                      }

                      // ------------------------------------------
                      // VEHICULE
                      // ------------------------------------------

                      final vehicule =
                      recupererVehicule(rdv);

                      final marque =
                          vehicule?["marque"]?.toString() ??
                              "Inconnue";

                      final modele =
                          vehicule?["modele"]?.toString() ?? "";

                      final immatriculation =
                          vehicule?["immatriculation"]
                              ?.toString() ??
                              "";

                      // ------------------------------------------
                      // STATUT
                      // ------------------------------------------

                      final statut =
                      rdv["statut"]?.toString();

                      // ------------------------------------------
                      // AFFICHAGE
                      // ------------------------------------------

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 20,
                        ),

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            Text(
                              "Garagiste : $nomGaragiste",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Téléphone : "
                                  "$telephoneGaragiste",
                            ),

                            const SizedBox(height: 6),

                            Text(
                              "Adresse : "
                                  "$adresseGaragiste",
                            ),

                            const SizedBox(height: 8),

                            Text(
                              "Véhicule : "
                                  "$marque $modele",
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Date : "
                                  "${date.day.toString().padLeft(2, '0')}/"
                                  "${date.month.toString().padLeft(2, '0')}/"
                                  "${date.year}",
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Immatriculation : "
                                  "$immatriculation",
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Heure : "
                                  "${rdv["heureDebut"] ?? ""} - "
                                  "${rdv["heureFin"] ?? ""}",
                            ),

                            const SizedBox(height: 5),

                            Text(
                              "Statut : "
                                  "${afficherStatut(statut)}",

                              style: TextStyle(
                                color: couleurStatut(
                                  statut,
                                ),
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const Divider(
                              height: 25,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}