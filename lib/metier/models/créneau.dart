import 'package:flutter/material.dart';

class DisponibilitesPage extends StatefulWidget {
  const DisponibilitesPage({Key? key}) : super(key: key);

  @override
  State<DisponibilitesPage> createState() => _DisponibilitesPageState();
}

class _DisponibilitesPageState extends State<DisponibilitesPage> {
  final List<Map<String, dynamic>> disponibilites = [
    {
      "jour": "Lundi",
      "disponible": false,
      "heureDebut": null,
      "heureFin": null,
    },
    {
      "jour": "Mardi",
      "disponible": false,
      "heureDebut": null,
      "heureFin": null,
    },
    {
      "jour": "Mercredi",
      "disponible": false,
      "heureDebut": null,
      "heureFin": null,
    },
    {
      "jour": "Jeudi",
      "disponible": false,
      "heureDebut": null,
      "heureFin": null,
    },
    {
      "jour": "Vendredi",
      "disponible": false,
      "heureDebut": null,
      "heureFin": null,
    },
    {
      "jour": "Samedi",
      "disponible": false,
      "heureDebut": null,
      "heureFin": null,
    },
  ];

  Future<void> choisirHeure(int index, bool debut) async {
    final TimeOfDay? heure = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (heure != null) {
      setState(() {
        if (debut) {
          disponibilites[index]["heureDebut"] = heure;
        } else {
          disponibilites[index]["heureFin"] = heure;
        }
      });
    }
  }

  String afficherHeure(TimeOfDay? heure) {
    if (heure == null) return "--:--";

    return heure.hour.toString().padLeft(2, '0') +
        ":" +
        heure.minute.toString().padLeft(2, '0');
  }

  void enregistrer() {
    for (var d in disponibilites) {
      debugPrint(d.toString());
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Disponibilités enregistrées avec succès."),
      ),
    );

    // Ici plus tard tu enverras les données vers ton API Node.js.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes disponibilités"),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(15),
        itemCount: disponibilites.length,
        itemBuilder: (context, index) {
          final jour = disponibilites[index];

          return Card(
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          jour["jour"],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      Switch(
                        value: jour["disponible"],
                        onChanged: (value) {
                          setState(() {
                            jour["disponible"] = value;
                          });
                        },
                      ),
                    ],
                  ),

                  if (jour["disponible"]) ...[
                    const SizedBox(height: 10),

                    Row(
                      children: [

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => choisirHeure(index, true),
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              afficherHeure(jour["heureDebut"]),
                            ),
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => choisirHeure(index, false),
                            icon: const Icon(Icons.access_time_filled),
                            label: Text(
                              afficherHeure(jour["heureFin"]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: ElevatedButton(
          onPressed: enregistrer,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
          child: const Text(
            "Enregistrer les disponibilités",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}