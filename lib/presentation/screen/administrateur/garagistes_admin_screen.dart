import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';

class GaragistesAdminScreen extends StatefulWidget {
  final UserModel user;

  const GaragistesAdminScreen({
    super.key,
    required this.user,
  });

  @override
  State<GaragistesAdminScreen> createState() =>
      _GaragistesAdminScreenState();
}

class _GaragistesAdminScreenState
    extends State<GaragistesAdminScreen> {

  List<dynamic> garagistes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    chargerGaragistes();
  }

  Future<void> chargerGaragistes() async {
    try {
      final data = await ApiService.getGaragistes();

      if (!mounted) return;

      setState(() {
        garagistes = data;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Garagistes"),

        actions: [

          IconButton(
            onPressed: chargerGaragistes,
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
          : garagistes.isEmpty
          ? const Center(
        child: Text(
          "Aucun garagiste trouvé",
          style: TextStyle(fontSize: 16),
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: garagistes.length,
        itemBuilder: (context, index) {
          final garagiste = garagistes[index];

          final nom =
              garagiste["nom"]?.toString() ?? "Inconnu";

          final email =
              garagiste["email"]?.toString() ??
                  "Non renseigné";

          final telephone =
              garagiste["telephone"]?.toString() ??
                  "Non renseigné";

          final adresse =
              garagiste["adresse"]?.toString() ??
                  "Non renseignée";

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.build),
              ),

              title: Text(
                nom,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),

              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  Text("Email : $email"),
                  Text("Téléphone : $telephone"),
                  Text("Adresse : $adresse"),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}