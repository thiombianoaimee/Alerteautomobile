import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';

class CreneauAdminScreen extends StatefulWidget {
  final String garagisteId;
  final String nomGaragiste;

  const CreneauAdminScreen({
    super.key,
    required this.garagisteId,
    required this.nomGaragiste,
  });

  @override
  State<CreneauAdminScreen> createState() =>
      _CreneauAdminScreenState();
}

class _CreneauAdminScreenState
    extends State<CreneauAdminScreen> {

  List<dynamic> creneaux = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerCreneaux();
  }

  Future<void> chargerCreneaux() async {
    try {
      final data =
      await ApiService.getCreneauxByGaragiste(
        widget.garagisteId,
      );

      if (!mounted) return;

      setState(() {
        creneaux = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Disponibilités - ${widget.nomGaragiste}",
        ),
        actions: [
          IconButton(
            onPressed: chargerCreneaux,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )

          : creneaux.isEmpty
          ? const Center(
        child: Text(
          "Aucune disponibilité trouvée",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      )

          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: creneaux.length,

        itemBuilder: (context, index) {
          final creneau = creneaux[index];

          final jourDebut =
              creneau["jourDebut"]
                  ?.toString() ??
                  "Non renseigné";

          final jourFin =
              creneau["jourFin"]
                  ?.toString() ??
                  "Non renseigné";

          final heureDebut =
              creneau["heureDebut"]
                  ?.toString() ??
                  "Non renseignée";

          final heureFin =
              creneau["heureFin"]
                  ?.toString() ??
                  "Non renseignée";

          return Card(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),

            child: Padding(
              padding:
              const EdgeInsets.all(12),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [

                  Row(
                    children: [

                      const CircleAvatar(
                        child: Icon(
                          Icons.access_time,
                        ),
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          "Disponibilité ${index + 1}",
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
                    "Jours : $jourDebut - $jourFin",
                  ),

                  const SizedBox(
                    height: 5,
                  ),

                  Text(
                    "Horaires : "
                        "$heureDebut - $heureFin",
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