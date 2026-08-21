import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class RendezVousAdminScreen extends StatefulWidget {
  final String automobilisteId;

  const RendezVousAdminScreen({
    super.key,
    required this.automobilisteId,
  });
  @override
  State<RendezVousAdminScreen> createState() =>
      _RendezVousAdminScreenState();
}

class _RendezVousAdminScreenState
    extends State<RendezVousAdminScreen> {

  List<dynamic> rendezVous = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerRendezVous();
  }

  Future<void> chargerRendezVous() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("Token introuvable");
      }

      final data =
      await ApiService.getAllAppointments(token);
      final rdvAutomobiliste = data.where((rdv) {
        final automobiliste = rdv["automobiliste"];

        if (automobiliste == null || automobiliste is! Map) {
          return false;
        }

        return automobiliste["_id"]?.toString() ==
            widget.automobilisteId;
      }).toList();

      if (!mounted) return;

      setState(() {
        rendezVous = rdvAutomobiliste;
        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
        ),
      );
    }
  }

  String formaterDate(dynamic date) {

    if (date == null ||
        date.toString().isEmpty) {
      return "Non renseignée";
    }

    try {

      final dateTime =
      DateTime.parse(date.toString());

      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year}";

    } catch (_) {

      return date.toString();

    }
  }

  String formaterStatut(dynamic statut) {

    switch (statut) {

      case "en_attente":
        return "En attente";

      case "confirme":
        return "Confirmé";

      case "annule":
        return "Annulé";

      default:
        return "Inconnu";
    }
  }

  Color couleurStatut(dynamic statut) {

    switch (statut) {

      case "en_attente":
        return Colors.orange;

      case "confirme":
        return Colors.green;

      case "annule":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Rendez-vous"),
      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : rendezVous.isEmpty

          ? const Center(
        child: Text(
          "Aucun rendez-vous enregistré",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      )

          : RefreshIndicator(

        onRefresh: chargerRendezVous,

        child: ListView.builder(

          padding:
          const EdgeInsets.all(16),

          itemCount:
          rendezVous.length,

          itemBuilder:
              (context, index) {

            final rdv =
            rendezVous[index];

            final garagiste =
                rdv["garagiste"] ?? {};

            final vehicule =
                rdv["vehicule"] ?? {};

            final statut =
            rdv["statut"];

            return Container(

              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),

              padding:
              const EdgeInsets.all(16),

              decoration:
              BoxDecoration(

                border: Border.all(
                  color:
                  Colors.grey.shade300,
                ),

                borderRadius:
                BorderRadius.circular(10),
              ),

              child: Column(

                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  // Titre
                  Row(

                    children: [

                      const Icon(
                        Icons.calendar_month,
                        color: Colors.blue,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          "Rendez-vous ${index + 1}",
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                      // Statut
                      Container(

                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),

                        decoration:
                        BoxDecoration(

                          color:
                          couleurStatut(
                              statut)
                              .withValues(
                            alpha: 0.1,
                          ),

                          borderRadius:
                          BorderRadius
                              .circular(8),
                        ),

                        child: Text(

                          formaterStatut(
                              statut),

                          style: TextStyle(

                            color:
                            couleurStatut(
                                statut),

                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 15,
                  ),

                  // Date
                  Text(
                    "Date : "
                        "${formaterDate(
                      rdv["dateRdv"],
                    )}",
                    style:
                    const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // Heure
                  Text(
                    "Heure : "
                        "${rdv["heureDebut"] ?? "--"}"
                        " - "
                        "${rdv["heureFin"] ?? "--"}",
                    style:
                    const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const Divider(
                    height: 25,
                  ),

                  // Garagiste
                  Text(
                    "Garagiste : "
                        "${garagiste["nom"] ?? "Inconnu"}",
                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.w500,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // Véhicule
                  Text(
                    "Véhicule : "
                        "${vehicule["marque"] ?? ""} "
                        "${vehicule["modele"] ?? ""}",
                    style:
                    const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // Immatriculation
                  Text(
                    "Immatriculation : "
                        "${vehicule["immatriculation"] ?? "Non renseignée"}",
                    style:
                    const TextStyle(
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}