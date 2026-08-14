import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';

class RendezVousAdminScreen extends StatefulWidget {
  final UserModel user;

  const RendezVousAdminScreen({
    super.key,
    required this.user,
  });

  @override
  State<RendezVousAdminScreen> createState() =>
      _RendezVousAdminScreenState();
}

class _RendezVousAdminScreenState
    extends State<RendezVousAdminScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Gestion des rendez-vous",
        ),

        centerTitle: true,

        actions: [
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

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text(
              "Suivi des rendez-vous",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: [

                _statusCard(
                  "Confirmés",
                  Icons.check_circle,
                ),

                _statusCard(
                  "En attente",
                  Icons.hourglass_empty,
                ),

                _statusCard(
                  "Annulés",
                  Icons.cancel,
                ),

              ],
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                "Aucun rendez-vous disponible",
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }

  Widget _statusCard(
      String titre,
      IconData icon,
      ) {
    return Card(
      elevation: 3,

      child: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [

            Icon(
              icon,
              size: 35,
            ),

            const SizedBox(height: 8),

            Text(
              titre,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

          ],
        ),
      ),
    );
  }
}