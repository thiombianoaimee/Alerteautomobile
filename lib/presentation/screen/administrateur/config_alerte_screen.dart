import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class ConfigAlerteScreen extends StatefulWidget {
  final UserModel user;

  const ConfigAlerteScreen({super.key, required this.user});

  @override
  State<ConfigAlerteScreen> createState() => _ConfigAlerteScreenState();
}

class _ConfigAlerteScreenState extends State<ConfigAlerteScreen> {
  List<Map<String, dynamic>> alertes = [];
  bool chargement = true;
  bool enRegistre = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _chargerConfig();
  }

  Future<void> _chargerConfig() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return;
      
      final data = await ApiService.getAlertConfigs(token);
      
      // Le backend renvoie { "regles": [...] }
      if (data is Map && data.containsKey('regles')) {
        final List<dynamic> reglesList = data['regles'];
        if (!mounted) return;
        setState(() {
          alertes = reglesList.map((regle) => {
            "jours": regle["joursAvant"] ?? 0,
            "heure": regle["heure"] ?? "09:00",
            "actif": true,
          }).toList();
          chargement = false;
        });
      } else {
        throw Exception("Format de données invalide");
      }
    } catch (e) {
      // Si l'API n'existe pas encore ou erreur, on met des valeurs par défaut pour le dev
      setState(() {
        alertes = [
          {"jours": 30, "heure": "09:00", "actif": true},
          {"jours": 7, "heure": "09:00", "actif": true},
          {"jours": 3, "heure": "09:00", "actif": true},
          {"jours": 1, "heure": "18:00", "actif": true},
        ];
        chargement = false;
      });
    }
  }

  Future<void> _enregistrer() async {
    // 1. Vérification de l'unicité des jours (pour éviter les erreurs Backend)
    final joursVus = <int>{};
    for (var alerte in alertes) {
      if (joursVus.contains(alerte['jours'])) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur : Le seuil de ${alerte['jours']} jours existe déjà."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      joursVus.add(alerte['jours']);
    }

    setState(() => enRegistre = true);
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        // 2. Transformer les données au format attendu par le Backend (joursAvant)
        final regles = alertes.map((alerte) => {
          "joursAvant": alerte["jours"],
          "heure": alerte["heure"],
        }).toList();

        await ApiService.updateAlertConfigs(token, regles);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Configuration enregistrée avec succès !"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur : ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => enRegistre = false);
    }
  }

  void _ajouterAlerte() {
    setState(() {
      // On cherche un nombre de jours qui n'est pas encore utilisé (ex: le plus grand + 1)
      int nouveauJour = 1;
      if (alertes.isNotEmpty) {
        final jours = alertes.map((e) => e['jours'] as int).toList();
        jours.sort();
        nouveauJour = jours.last + 1;
      }

      alertes.add({"jours": nouveauJour, "heure": "09:00", "actif": true});
    });

    // On scrolle vers le bas pour voir le nouvel élément
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(int index) async {
    // Sécurisation de l'heure actuelle de l'alerte
    int initialHour = 9;
    int initialMinute = 0;

    try {
      final parts = alertes[index]["heure"].split(":");
      if (parts.length >= 2) {
        initialHour = int.tryParse(parts[0]) ?? 9;
        initialMinute = int.tryParse(parts[1]) ?? 0;
      }
    } catch (_) {}

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dial,
      helpText: "SÉLECTIONNER L'HEURE",
      builder: (BuildContext context, Widget? child) {
        return child!;
      },
      initialTime: TimeOfDay(
        hour: initialHour,
        minute: initialMinute,
      ),
    );
    if (picked != null) {
      setState(() {
        alertes[index]["heure"] = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration Alertes"),
        elevation: 0,
      ),
      body: chargement
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: const Column(
                    children: [
                      Icon(Icons.notifications_active, size: 50, color: Colors.blue),
                      SizedBox(height: 10),
                      Text(
                        "Gérer les seuils de rappel",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Définissez quand les automobilistes recevront leurs alertes de visite technique.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(15),
                    itemCount: alertes.length,
                    itemBuilder: (context, index) {
                      final alerte = alertes[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.blue.shade50,
                                child: Text("${alerte['jours']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text("Rappel à ${alerte['jours']} j", 
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                        overflow: TextOverflow.ellipsis),
                                    GestureDetector(
                                      onTap: () => _selectTime(index),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Row(
                                          children: [
                                            const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${alerte['heure']}",
                                              style: const TextStyle(
                                                color: Colors.green, 
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                decoration: TextDecoration.underline
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Sélecteur de jours rapide
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: const Icon(Icons.remove_circle_outline, size: 22),
                                    onPressed: () {
                                      if (alerte['jours'] > 1) {
                                        setState(() => alertes[index]['jours']--);
                                      }
                                    },
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: const Icon(Icons.add_circle_outline, size: 22),
                                    onPressed: () {
                                      setState(() => alertes[index]['jours']++);
                                    },
                                  ),
                                  IconButton(
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(4),
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
                                    onPressed: () {
                                      setState(() => alertes.removeAt(index));
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      OutlinedButton.icon(
                        onPressed: _ajouterAlerte,
                        icon: const Icon(Icons.add),
                        label: const Text("Ajouter un nouveau seuil"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: enRegistre ? null : _enregistrer,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 55),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: enRegistre 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("ENREGISTRER LA CONFIGURATION", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
              ],
            ),
    );
  }
}
