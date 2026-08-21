import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class VehiculesAdminScreen extends StatefulWidget {
  final String automobilisteId;

  const VehiculesAdminScreen({
    super.key,
    required this.automobilisteId,
  });

  @override
  State<VehiculesAdminScreen> createState() =>
      _VehiculesAdminScreenState();
}

class _VehiculesAdminScreenState extends State<VehiculesAdminScreen> {
  List<dynamic> vehicules = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerVehicules();
  }

  Future<void> chargerVehicules() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("Token introuvable");
      }

      final data = await ApiService.getVehiclesByAutomobiliste(
        widget.automobilisteId,
        token,
      );

      if (!mounted) return;

      setState(() {
        vehicules = data;
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
    if (date == null || date.toString().isEmpty) {
      return "Non renseignée";
    }

    try {
      final dateTime = DateTime.parse(date.toString());

      return "${dateTime.day.toString().padLeft(2, '0')}/"
          "${dateTime.month.toString().padLeft(2, '0')}/"
          "${dateTime.year}";
    } catch (_) {
      return date.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Véhicules"),
      ),

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : vehicules.isEmpty
          ? const Center(
        child: Text(
          "Aucun véhicule enregistré",
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      )
          : RefreshIndicator(
        onRefresh: chargerVehicules,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: vehicules.length,
          itemBuilder: (context, index) {
            final vehicle = vehicules[index];

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Marque et modèle
                  Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Text(
                          "${vehicle["marque"] ?? "Inconnue"} "
                              "${vehicle["modele"] ?? ""}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  // Immatriculation
                  Text(
                    "Immatriculation : "
                        "${vehicle["immatriculation"] ?? "Non renseignée"}",
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Date visite technique
                  Text(
                    "Visite technique : "
                        "${formaterDate(
                      vehicle["dateVisiteTechnique"],
                    )}",
                    style: const TextStyle(
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