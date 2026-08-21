import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class RdvGaragisteAdminScreen extends StatefulWidget {
  final String garagisteId;
  final String nomGaragiste;

  const RdvGaragisteAdminScreen({
    super.key,
    required this.garagisteId,
    required this.nomGaragiste,
  });

  @override
  State<RdvGaragisteAdminScreen> createState() =>
      _RdvGaragisteAdminScreenState();
}

class _RdvGaragisteAdminScreenState
    extends State<RdvGaragisteAdminScreen> {

  List<dynamic> rendezVous = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerRendezVous();
  }

  Future<void> chargerRendezVous() async {
    try {
      final token =
      await StorageService.getToken();

      if (token == null) {
        throw Exception(
          "Token introuvable",
        );
      }

      // Récupérer tous les RDV
      final tousLesRdvs =
      await ApiService.getAllAppointments(
        token,
      );

      // Garder uniquement les RDV
      // du garagiste sélectionné
      final rdvsGaragiste =
      tousLesRdvs.where((rdv) {

        final garagiste =
        rdv["garagiste"];

        if (garagiste is Map) {
          return garagiste["_id"]?.toString() ==
              widget.garagisteId;
        }

        if (garagiste is String) {
          return garagiste ==
              widget.garagisteId;
        }

        return false;
      }).toList();

      if (!mounted) return;

      setState(() {
        rendezVous = rdvsGaragiste;
        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Erreur lors du chargement : $e",
          ),
        ),
      );
    }
  }

  String formaterDate(dynamic date) {
    if (date == null) {
      return "Non renseignée";
    }

    try {
      final parsed =
      DateTime.parse(
        date.toString(),
      );

      final jour =
      parsed.day.toString().padLeft(2, '0');

      final mois =
      parsed.month.toString().padLeft(2, '0');

      final annee =
      parsed.year.toString();

      return "$jour/$mois/$annee";

    } catch (_) {
      return date.toString();
    }
  }

  String obtenirNomAutomobiliste(
      dynamic automobiliste,
      ) {
    if (automobiliste is Map) {
      return automobiliste["nom"]
          ?.toString() ??
          "Inconnu";
    }

    return "Inconnu";
  }

  String obtenirTelephoneAutomobiliste(
      dynamic automobiliste,
      ) {
    if (automobiliste is Map) {
      return automobiliste["telephone"]
          ?.toString() ??
          "Non renseigné";
    }

    return "Non renseigné";
  }

  String obtenirVehicule(
      dynamic vehicule,
      ) {
    if (vehicule is Map) {

      final marque =
          vehicule["marque"]
              ?.toString() ??
              "";

      final modele =
          vehicule["modele"]
              ?.toString() ??
              "";

      final immatriculation =
          vehicule["immatriculation"]
              ?.toString() ??
              "";

      return "$marque $modele - $immatriculation";
    }

    return "Véhicule non renseigné";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: Text(
          "Rendez-vous - ${widget.nomGaragiste}",
        ),

        actions: [

          IconButton(
            onPressed:
            chargerRendezVous,

            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: isLoading

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

          : rendezVous.isEmpty

          ? const Center(
        child: Text(
          "Aucun rendez-vous trouvé",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      )

          : ListView.builder(

        padding:
        const EdgeInsets.all(10),

        itemCount:
        rendezVous.length,

        itemBuilder:
            (context, index) {

          final rdv =
          rendezVous[index];

          final automobiliste =
          rdv["automobiliste"];

          final vehicule =
          rdv["vehicule"];

          final date =
          formaterDate(
            rdv["dateRdv"],
          );

          final heureDebut =
              rdv["heureDebut"]
                  ?.toString() ??
                  "N/A";

          final heureFin =
              rdv["heureFin"]
                  ?.toString() ??
                  "N/A";

          final statut =
              rdv["statut"]
                  ?.toString() ??
                  "en_attente";

          return Card(

            margin:
            const EdgeInsets.only(
              bottom: 10,
            ),

            child: Padding(

              padding:
              const EdgeInsets.all(12),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment
                    .start,

                children: [

                  // =================================
                  // AUTOMOBILISTE
                  // =================================

                  Row(
                    children: [

                      const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          obtenirNomAutomobiliste(
                            automobiliste,
                          ),

                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Téléphone : "
                        "${obtenirTelephoneAutomobiliste(
                      automobiliste,
                    )}",
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // =================================
                  // VEHICULE
                  // =================================

                  Text(
                    "Véhicule : "
                        "${obtenirVehicule(
                      vehicule,
                    )}",
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // =================================
                  // DATE
                  // =================================

                  Text(
                    "Date : $date",
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  // =================================
                  // HEURE
                  // =================================

                  Text(
                    "Horaire : "
                        "$heureDebut - $heureFin",
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // =================================
                  // STATUT DU RDV
                  // =================================

                  Row(
                    children: [

                      const Text(
                        "Statut : ",
                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      Text(
                        statut ==
                            "confirme"
                            ? "Confirmé"
                            : statut ==
                            "annule"
                            ? "Annulé"
                            : "En attente",

                        style:
                        TextStyle(
                          fontWeight:
                          FontWeight.bold,

                          color:
                          statut ==
                              "confirme"
                              ? Colors.green
                              : statut ==
                              "annule"
                              ? Colors.red
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}