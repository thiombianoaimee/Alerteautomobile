import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';
import 'vehicule_admin_screen.dart';
import 'rdv_admin_screen.dart';
class AutomobilistesAdminScreen extends StatefulWidget {
  final UserModel user;

  const AutomobilistesAdminScreen({
    super.key,
    required this.user,
  });

  @override
  State<AutomobilistesAdminScreen> createState() =>
      _AutomobilistesAdminScreenState();
}

class _AutomobilistesAdminScreenState
    extends State<AutomobilistesAdminScreen> {

  List<dynamic> automobilistes = [];
  bool isLoading = true;
  Map<String, int> nombreVehicules = {};
  Map<String, int> nombreRdv = {};

  @override
  void initState() {
    super.initState();
    chargerAutomobilistes();
  }

  Future<void> chargerAutomobilistes() async {
    try {
      final data = await ApiService.getAutomobilistes();
      final token = await StorageService.getToken();


      if (token == null) {
        throw Exception("Token introuvable");
      }
      final rdvs = await ApiService.getAllAppointments(token);

      Map<String, int> compteurs = {};

      for (final automobiliste in data) {
        final id = automobiliste["_id"]?.toString();

        if (id != null) {
          final vehicules =
          await ApiService.getVehiclesByAutomobiliste(
            id,
            token,
          );

          compteurs[id] = vehicules.length;
        }
      }

      // Compteur des rendez-vous
      Map<String, int> compteursRdv = {};

      for (final rdv in rdvs) {
        final automobiliste =
        rdv["automobiliste"];

        if (automobiliste != null &&
            automobiliste is Map) {

          final id =
          automobiliste["_id"]?.toString();

          if (id != null) {
            compteursRdv[id] =
                (compteursRdv[id] ?? 0) + 1;
          }
        }
      }
      if (!mounted) return;

      setState(() {
        automobilistes = data;
        nombreVehicules = compteurs;
        nombreRdv= compteursRdv;
        isLoading = false;
      });

    } catch (e) {

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors du chargement : $e"),
        ),
      );
    }
  }

  // Activer ou désactiver un compte
  Future<void> changerStatut(
      Map<String, dynamic> automobiliste) async {

    try {

      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("Token introuvable");
      }

      final id = automobiliste["_id"]?.toString();

      if (id == null) {
        throw Exception(
          "ID de l'automobiliste introuvable",
        );
      }

      await ApiService.toggleUserStatus(
        id,
        token,
      );

      // Recharger la liste après modification
      await chargerAutomobilistes();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Statut du compte modifié avec succès",
          ),
        ),
      );

    } catch (e) {

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Automobilistes"),

        actions: [

          IconButton(
            onPressed: chargerAutomobilistes,
            icon: const Icon(Icons.refresh),
          ),

          IconButton(
            icon: const Icon(
              Icons.account_circle,
              size: 30,
            ),
            tooltip: "Mon profil",
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilAdminScreen(
                        user: widget.user,
                      ),
                ),
              );

            },
          ),

        ],
      ),

      body: isLoading

          ? const Center(
        child: CircularProgressIndicator(),
      )

          : automobilistes.isEmpty

          ? const Center(
        child: Text(
          "Aucun automobiliste trouvé",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      )

          : ListView.builder(

        padding: const EdgeInsets.all(10),

        itemCount: automobilistes.length,

        itemBuilder: (context, index) {

          final automobiliste =
          automobilistes[index];

          final nom =
              automobiliste["nom"]
                  ?.toString() ??
                  "Inconnu";

          final email =
              automobiliste["email"]
                  ?.toString() ??
                  "Non renseigné";

          final telephone =
              automobiliste["telephone"]
                  ?.toString() ??
                  "Non renseigné";

          final adresse =
              automobiliste["adresse"]
                  ?.toString() ??
                  "Non renseignée";

          final actif =
              automobiliste["actif"] != false;

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
                CrossAxisAlignment.start,

                children: [

                  // Nom + statut
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
                          nom,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),

                      Container(
                        padding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),

                        decoration: BoxDecoration(
                          color: actif
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        child: Text(
                          actif
                              ? "Actif"
                              : "Désactivé",
                          style: TextStyle(
                            color: actif
                                ? Colors.green
                                : Colors.red,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "Email : $email",
                  ),

                  Text(
                    "Téléphone : $telephone",
                  ),

                  Text(
                    "Adresse : $adresse",
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // Véhicules et RDV
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 20,
                      ),

                      const SizedBox(width: 5),

                      InkWell(
                        onTap: () {
                          final id = automobiliste["_id"]?.toString();

                          if (id == null) {
                            return;
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VehiculesAdminScreen(
                                automobilisteId: id,
                              ),
                            ),
                          );
                        },

                        child: Text(
                          "Véhicules : "
                              "${nombreVehicules[automobiliste["_id"]?.toString()] ?? 0}",

                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 25),

                      const Icon(
                        Icons.calendar_month,
                        size: 20,
                      ),

                      const SizedBox(width: 5),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RendezVousAdminScreen(
                                automobilisteId:
                                automobiliste["_id"]?.toString() ?? "",
                              ),
                            ),
                          );
                        },
                        child: Text(
                          "RDV : "
                              "${nombreRdv[
                          automobiliste["_id"]?.toString()
                          ] ?? 0}",
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    ],
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  // Statut + bouton
                  Row(

                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,

                    children: [

                      Text(
                        actif
                            ? "Statut : 🟢 Actif"
                            : "Statut : 🔴 Désactivé",
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),

                      ElevatedButton(

                        onPressed: () {
                          changerStatut(
                            automobiliste,
                          );
                        },

                        child: Text(
                          actif
                              ? "Désactiver"
                              : "Activer",
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