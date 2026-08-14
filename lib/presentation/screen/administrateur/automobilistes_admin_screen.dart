import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';

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

  @override
  void initState() {
    super.initState();
    chargerAutomobilistes();
  }

  Future<void> chargerAutomobilistes() async {
    try {
      final data = await ApiService.getAutomobilistes();
      if (!mounted) return;
      setState(() {
        automobilistes = data;
        isLoading = false;
      });
    } catch (e) {
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
                  builder: (context) => ProfilAdminScreen(
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
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: automobilistes.length,
        itemBuilder: (context, index) {

          final automobiliste = automobilistes[index];

          final nom =
              automobiliste["nom"]?.toString() ?? "Inconnu";

          final email =
              automobiliste["email"]?.toString() ?? "Non renseigné";

          final telephone =
              automobiliste["telephone"]?.toString() ??
                  "Non renseigné";

          final adresse =
              automobiliste["adresse"]?.toString() ??
                  "Non renseignée";

          return Card(
            margin: const EdgeInsets.only(bottom: 2),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    child: Icon(Icons.person),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nom,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text("Email : $email"),

                        Text("Téléphone : $telephone"),

                        Text("Adresse : $adresse"),
                      ],
                    ),
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