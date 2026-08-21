import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_auto_screen.dart';

class RendezVousScreen extends StatefulWidget {
  final UserModel user;

  const RendezVousScreen({
    super.key,
    required this.user,
  });

  @override
  State<RendezVousScreen> createState() => _RendezVousScreenState();
}

class _RendezVousScreenState extends State<RendezVousScreen> {

  // ============================================================
  // GARAGISTE
  // ============================================================

  String? garagisteIdSelectionne;
  String? nomGaragisteSelectionne;

  List<dynamic> garagistes = [];
  bool chargementGaragistes = false;

  // ============================================================
  // DATE
  // ============================================================

  DateTime? dateSelectionnee;

  // ============================================================
  // CRENEAUX
  // ============================================================

  List<dynamic> creneaux = [];
  bool chargementCreneaux = false;

  String? creneauSelectionne;

  // ============================================================
  // VEHICULES
  // ============================================================

  List<dynamic> vehicules = [];
  bool chargementVehicules = true;

  String? vehiculeSelectionne;
  String? nomVehiculeSelectionne;

  @override
  void initState() {
    super.initState();

    // On charge uniquement les véhicules au démarrage.
    // Les garagistes seront chargés après le choix de la date.
    chargerVehicules();
  }

  // ============================================================
  // CHARGER LES GARAGISTES DISPONIBLES POUR UNE DATE
  // ============================================================

  Future<void> chargerGaragistesDisponibles() async {

    if (dateSelectionnee == null) {
      return;
    }

    try {

      setState(() {
        chargementGaragistes = true;

        // Réinitialiser les anciennes sélections
        garagistes = [];
        garagisteIdSelectionne = null;
        nomGaragisteSelectionne = null;

        creneaux = [];
        creneauSelectionne = null;
      });

      // --------------------------------------------------------
      // Format YYYY-MM-DD
      // --------------------------------------------------------

      final String date =
          "${dateSelectionnee!.year}-"
          "${dateSelectionnee!.month.toString().padLeft(2, '0')}-"
          "${dateSelectionnee!.day.toString().padLeft(2, '0')}";

      // --------------------------------------------------------
      // Appel du nouveau endpoint
      // --------------------------------------------------------

      final Map<String, dynamic> data =
      await ApiService.getGaragistesDisponibles(date);

      if (!mounted) return;

      // --------------------------------------------------------
      // Récupérer la liste des garagistes
      // --------------------------------------------------------

      final List<dynamic> liste =
          (data["garagistes"] as List?) ?? [];

      setState(() {

        garagistes = liste;

        chargementGaragistes = false;

      });

    } catch (e) {

      debugPrint(
        "Erreur chargement garagistes disponibles : $e",
      );

      if (!mounted) return;

      setState(() {
        chargementGaragistes = false;
        garagistes = [];
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur récupération des garagistes : $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // CHOISIR UNE DATE
  // ============================================================

  Future<void> choisirDate() async {

    final DateTime maintenant = DateTime.now();

    final DateTime? date = await showDatePicker(

      context: context,

      initialDate: maintenant,

      firstDate: maintenant,

      lastDate: DateTime(2100),

      locale: const Locale('fr', 'FR'),
    );

    if (date == null) {
      return;
    }

    setState(() {

      dateSelectionnee = date;

      // Réinitialiser les anciennes sélections
      garagisteIdSelectionne = null;
      nomGaragisteSelectionne = null;

      creneaux = [];
      creneauSelectionne = null;

    });

    // ----------------------------------------------------------
    // Une fois la date choisie :
    // rechercher les garagistes disponibles
    // ----------------------------------------------------------

    await chargerGaragistesDisponibles();
  }

  // ============================================================
  // CHOISIR UN GARAGISTE
  // ============================================================

  void choisirGaragiste(
      Map<String, dynamic> garagiste,
      ) {

    final List<dynamic> disponibilites =
        (garagiste["creneauxDisponibles"] as List?) ?? [];

    setState(() {

      garagisteIdSelectionne =
          garagiste["_id"]?.toString();

      nomGaragisteSelectionne =
          garagiste["nom"]?.toString();

      // Les créneaux viennent directement du backend
      creneaux = disponibilites;

      creneauSelectionne = null;

    });
  }

  // ============================================================
  // CHARGER LES VEHICULES
  // ============================================================

  Future<void> chargerVehicules() async {

    try {

      final String? token =
      await StorageService.getToken();

      if (token == null) {

        if (!mounted) return;

        setState(() {
          chargementVehicules = false;
        });

        return;
      }

      final List<dynamic> liste =
      await ApiService.getMyVehicles(token);

      if (!mounted) return;

      setState(() {

        vehicules = liste;

        chargementVehicules = false;

      });

    } catch (e) {

      debugPrint(
        "Erreur chargement véhicules : $e",
      );

      if (!mounted) return;

      setState(() {
        chargementVehicules = false;
      });
    }
  }

  // ============================================================
  // CREER LE RENDEZ-VOUS
  // ============================================================

  Future<void> confirmerRendezVous() async {

    final messenger =
    ScaffoldMessenger.of(context);

    // ==========================================================
    // VERIFICATION DES SELECTIONS
    // ==========================================================

    if (dateSelectionnee == null) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez choisir une date.",
          ),
        ),
      );

      return;
    }

    if (garagisteIdSelectionne == null) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez choisir un garagiste.",
          ),
        ),
      );

      return;
    }

    if (creneauSelectionne == null) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez choisir un créneau.",
          ),
        ),
      );

      return;
    }

    if (vehiculeSelectionne == null) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez choisir un véhicule.",
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // RECUPERER LE TOKEN
    // ==========================================================

    final String? token =
    await StorageService.getToken();

    if (!mounted) return;

    if (token == null) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Utilisateur non connecté.",
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // RECUPERER L'ID AUTOMOBILISTE
    // ==========================================================

    final String? automobilisteId =
    await StorageService.getUserId();

    if (!mounted) return;

    if (automobilisteId == null) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Identifiant utilisateur introuvable.",
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // SEPARER LE CRENEAU
    //
    // Exemple :
    // "08:00 - 09:00"
    // ==========================================================

    final List<String> heures =
    creneauSelectionne!.split(" - ");

    if (heures.length != 2) {

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            "Format du créneau incorrect.",
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // FORMATER LA DATE
    // ==========================================================

    final String dateRdv =
        "${dateSelectionnee!.year}-"
        "${dateSelectionnee!.month.toString().padLeft(2, '0')}-"
        "${dateSelectionnee!.day.toString().padLeft(2, '0')}";

    // ==========================================================
    // DONNEES DU RENDEZ-VOUS
    // ==========================================================

    final Map<String, dynamic> rdvData = {

      "automobiliste":
      automobilisteId,

      "garagiste":
      garagisteIdSelectionne,

      "vehicule":
      vehiculeSelectionne,

      "date":
      dateRdv,

      "heureDebut":
      heures[0],

      "heureFin":
      heures[1],
    };

    // ==========================================================
    // CREATION
    // ==========================================================

    try {

      final Map<String, dynamic> resultat =
      await ApiService.creerRdv(
        rdvData,
        token,
      );

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            resultat["message"] ??
                "Rendez-vous créé avec succès.",
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Erreur : $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // INTERFACE
  // ============================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Planifier sa visite technique",
        ),

        centerTitle: true,

        actions: [

          IconButton(

            icon: const Icon(
              Icons.notifications,
            ),

            onPressed: () {

              Navigator.pushNamed(
                context,
                '/notifications',
              );

            },
          ),

          IconButton(

            icon: const Icon(
              Icons.person,
            ),

            onPressed: () {

              Navigator.push(

                context,

                MaterialPageRoute(

                  builder: (context) =>
                      ProfilAutoScreen(
                        user: widget.user,
                      ),

                ),
              );

            },
          ),
        ],
      ),

      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [

            // ==================================================
            // ETAPE 1 : DATE
            // ==================================================

            const Text(

              "🟢 1. Choisir une date",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,

                color: Colors.green,
              ),
            ),

            const SizedBox(height: 15),

            ElevatedButton.icon(

              onPressed: choisirDate,

              icon: const Icon(
                Icons.calendar_month,
              ),

              label: Text(

                dateSelectionnee == null

                    ? "Choisir une date"

                    : "${dateSelectionnee!.day.toString().padLeft(2, '0')}/"
                    "${dateSelectionnee!.month.toString().padLeft(2, '0')}/"
                    "${dateSelectionnee!.year}",
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // ETAPE 2 : GARAGISTES DISPONIBLES
            // ==================================================

            const Text(

              "🔵 2. Choisir un garagiste",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,

                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 15),

            if (dateSelectionnee == null)

              const Text(
                "Choisissez d'abord une date.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              )

            else if (chargementGaragistes)

              const Center(
                child:
                CircularProgressIndicator(),
              )

            else if (garagistes.isEmpty)

                const Text(

                  "Aucun garagiste disponible "
                      "pour cette date.",

                  style: TextStyle(
                    color: Colors.red,
                  ),
                )

              else

                ListView.builder(

                  shrinkWrap: true,

                  physics:
                  const NeverScrollableScrollPhysics(),

                  itemCount:
                  garagistes.length,

                  itemBuilder:
                      (context, index) {

                    final Map<String, dynamic>
                    garagiste =
                    Map<String, dynamic>.from(
                      garagistes[index],
                    );

                    final bool selectionne =
                        garagisteIdSelectionne ==
                            garagiste["_id"]?.toString();


                    return Card(

                      margin:
                      const EdgeInsets.only(
                        bottom: 15,
                      ),

                      child: Padding(

                        padding:
                        const EdgeInsets.all(15),

                        child: Column(

                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [

                            Text(

                              garagiste["nom"] ??
                                  "Garagiste",

                              style:
                              const TextStyle(

                                fontSize: 18,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(

                              "Téléphone : "
                                  "${garagiste["telephone"] ?? "Non renseigné"}",
                            ),

                            const SizedBox(height: 5),

                            Text(

                              "Adresse : "
                                  "${garagiste["adresse"] ?? "Non renseignée"}",
                            ),


                            const SizedBox(height: 10),
                            SizedBox(

                              width:
                              double.infinity,

                              child:
                              ElevatedButton(

                                onPressed: () {

                                  choisirGaragiste(
                                    garagiste,
                                  );

                                },

                                child: Text(

                                  selectionne
                                      ? "Garagiste sélectionné"
                                      : "Choisir",

                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

            const Divider(height: 40),

            // ==================================================
            // ETAPE 3 : CRENEAU
            // ==================================================

            const Text(

              "🔵 3. Choisir un créneau",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,

                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 15),

            if (garagisteIdSelectionne == null)

              const Text(
                "Choisissez d'abord un garagiste.",
                style: TextStyle(
                  color: Colors.grey,
                ),
              )

            else if (chargementCreneaux)

              const Center(
                child:
                CircularProgressIndicator(),
              )

            else if (creneaux.isEmpty)

                const Text(

                  "Aucun créneau disponible.",

                  style: TextStyle(
                    color: Colors.red,
                  ),
                )

              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: creneaux.length,
                  itemBuilder: (context, index) {
                    final creneau = creneaux[index];

                    final String heure =
                        "${creneau["heureDebut"]} - "
                        "${creneau["heureFin"]}";

                    final bool selectionne =
                        creneauSelectionne == heure;

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: ListTile(
                        title: Text(heure),
                        trailing: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              creneauSelectionne = heure;
                            });
                          },
                          child: Text(
                            selectionne
                                ? "Sélectionné"
                                : "Choisir",
                          ),
                        ),
                      ),
                    );
                  },
                ),

            const Divider(height: 40),

            // ==================================================
            // ETAPE 4 : VEHICULE
            // ==================================================

            const Text(

              "🟣 4. Choisir un véhicule",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,

                color: Colors.purple,
              ),
            ),

            const SizedBox(height: 15),

            if (chargementVehicules)

              const Center(
                child:
                CircularProgressIndicator(),
              )

            else if (vehicules.isEmpty)

              const Text(

                "Aucun véhicule enregistré.",

                style: TextStyle(
                  color: Colors.red,
                ),
              )

            else

              Column(

                children:
                vehicules.map((vehicule) {

                  final String id =
                      vehicule["_id"]?.toString() ??
                          "";

                  final String nom =

                      "${vehicule["marque"] ?? ""} "
                      "${vehicule["modele"] ?? ""}";

                  final bool selectionne =
                      vehiculeSelectionne ==
                          id;

                  return Card(

                    margin:
                    const EdgeInsets.only(
                      bottom: 15,
                    ),

                    child: Padding(

                      padding:
                      const EdgeInsets.all(15),

                      child: Row(

                        children: [

                          Expanded(

                            child: Text(

                              nom,

                              style:
                              const TextStyle(

                                fontSize: 18,

                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ),

                          ElevatedButton(

                            onPressed: () {

                              setState(() {

                                vehiculeSelectionne =
                                    id;

                                nomVehiculeSelectionne =
                                    nom;

                              });

                            },

                            child: Text(

                              selectionne
                                  ? "Sélectionné"
                                  : "Choisir",

                            ),
                          ),
                        ],
                      ),
                    ),
                  );

                }).toList(),
              ),

            const Divider(height: 40),

            // ==================================================
            // ETAPE 5 : CONFIRMATION
            // ==================================================

            const Text(

              "🟢 5. Confirmation du rendez-vous",

              style: TextStyle(

                fontSize: 22,

                fontWeight:
                FontWeight.bold,

                color: Colors.green,
              ),
            ),

            const SizedBox(height: 15),

            Text(

              "Garagiste : "
                  "${nomGaragisteSelectionne ?? "Non sélectionné"}",
            ),

            const SizedBox(height: 5),

            Text(

              "Véhicule : "
                  "${nomVehiculeSelectionne ?? "Non sélectionné"}",
            ),

            const SizedBox(height: 5),

            Text(

              "Date : "

                  "${dateSelectionnee == null
                  ? "Non sélectionnée"
                  : "${dateSelectionnee!.day.toString().padLeft(2, '0')}/"
                  "${dateSelectionnee!.month.toString().padLeft(2, '0')}/"
                  "${dateSelectionnee!.year}"}",
            ),

            const SizedBox(height: 5),

            Text(

              "Créneau : "
                  "${creneauSelectionne ?? "Non sélectionné"}",
            ),

            const SizedBox(height: 25),

            // ==================================================
            // BOUTON CONFIRMER
            // ==================================================

            SizedBox(

              width:
              double.infinity,

              child:
              ElevatedButton.icon(

                onPressed:
                confirmerRendezVous,

                icon: const Icon(
                  Icons.check_circle,
                ),

                label: const Text(
                  "Confirmer le rendez-vous",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}