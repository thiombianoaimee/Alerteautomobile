import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/storage_service.dart';
import 'profil_admin_screen.dart';

class SupervisionAdminScreen extends StatefulWidget {
  final UserModel user;

  const SupervisionAdminScreen({
    super.key,
    required this.user,
  });

  @override
  State<SupervisionAdminScreen> createState() =>
      _SupervisionAdminScreenState();
}

class _SupervisionAdminScreenState
    extends State<SupervisionAdminScreen> {
  Map<String, dynamic>? statistiques;

  bool chargement = true;

  String? erreur;

  // ============================================================
  // INITIALISATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    chargerStatistiques();
  }

  // ============================================================
  // CHARGER LES STATISTIQUES
  // ============================================================

  Future<void> chargerStatistiques() async {
    try {
      setState(() {
        chargement = true;
        erreur = null;
      });

      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("Token introuvable");
      }

      final data = await ApiService.getStatistiques(token);

      if (!mounted) return;

      setState(() {
        statistiques = data;
        chargement = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        erreur = e.toString();
        chargement = false;
      });
    }
  }

  // ============================================================
  // INTERFACE PRINCIPALE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Supervision",
        ),

        actions: [
          // ------------------------------------------------------
          // ACTUALISER
          // ------------------------------------------------------

          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip: "Actualiser",
            onPressed: chargerStatistiques,
          ),

          // ------------------------------------------------------
          // PROFIL ADMIN
          // ------------------------------------------------------

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

      body: _construireContenu(),
    );
  }

  // ============================================================
  // CONSTRUIRE LE CONTENU
  // ============================================================

  Widget _construireContenu() {
    // ----------------------------------------------------------
    // CHARGEMENT
    // ----------------------------------------------------------

    if (chargement) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // ----------------------------------------------------------
    // ERREUR
    // ----------------------------------------------------------

    if (erreur != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
            ),

            const SizedBox(height: 15),

            const Text(
              "Impossible de charger les statistiques",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: chargerStatistiques,
              child: const Text(
                "Réessayer",
              ),
            ),
          ],
        ),
      );
    }

    // ----------------------------------------------------------
    // AUCUNE STATISTIQUE
    // ----------------------------------------------------------

    if (statistiques == null) {
      return const Center(
        child: Text(
          "Aucune statistique disponible",
        ),
      );
    }

    // ----------------------------------------------------------
    // RECUPERATION DES DONNEES
    // ----------------------------------------------------------

    final utilisateurs =
    statistiques!["utilisateurs"];

    final rendezVous =
    statistiques!["rendezVous"];

    // ==========================================================
    // SCROLL VERTICAL
    // ==========================================================

    return RefreshIndicator(
      onRefresh: chargerStatistiques,

      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.all(12),

        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            // ====================================================
            // TITRE
            // ====================================================

            const Text(
              "Tableau de supervision",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              "Vue globale de l'activité de l'application",
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            // ====================================================
            // UTILISATEURS
            // ====================================================

            Row(
              children: const [
                Icon(
                  Icons.people,
                  color: Colors.blue,
                ),

                SizedBox(width: 8),

                Text(
                  "Utilisateurs",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // AUTOMOBILISTES / GARAGISTES
            // ----------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Automobilistes",
                    utilisateurs["automobilistes"],
                    Icons.person,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "Garagistes",
                    utilisateurs["garagistes"],
                    Icons.build,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // COMPTES ACTIFS / DESACTIVES
            // ----------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Comptes actifs",
                    utilisateurs["comptesActifs"],
                    Icons.check_circle,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "Comptes désactivés",
                    utilisateurs["comptesDesactives"],
                    Icons.cancel,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ====================================================
            // VEHICULES
            // ====================================================

            Row(
              children: const [
                Icon(
                  Icons.directions_car,
                  color: Colors.blue,
                ),

                SizedBox(width: 8),

                Text(
                  "Véhicules",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _statCard(
              "Total véhicules",
              statistiques!["vehicules"],
              Icons.directions_car,
            ),

            const SizedBox(height: 24),

            // ====================================================
            // RENDEZ-VOUS
            // ====================================================

            Row(
              children: const [
                Icon(
                  Icons.calendar_month,
                  color: Colors.blue,
                ),

                SizedBox(width: 8),

                Text(
                  "Rendez-vous",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // TOTAL / CONFIRMES
            // ----------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "Total",
                    rendezVous["total"],
                    Icons.calendar_month,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "Confirmés",
                    rendezVous["confirmes"],
                    Icons.check_circle,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // EN ATTENTE / ANNULES
            // ----------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _statCard(
                    "En attente",
                    rendezVous["enAttente"],
                    Icons.hourglass_empty,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: _statCard(
                    "Annulés",
                    rendezVous["annules"],
                    Icons.cancel,
                  ),
                ),
              ],
            ),

            // ====================================================
            // ESPACE EN BAS
            // ====================================================

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CARTE STATISTIQUE
  // ============================================================

  Widget _statCard(
      String titre,
      dynamic valeur,
      IconData icon,
      ) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),

      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 14,
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            // ----------------------------------------------------
            // ICONE
            // ----------------------------------------------------

            CircleAvatar(
              radius: 22,

              backgroundColor:
              Colors.blue.withValues(
                alpha: 0.1,
              ),

              child: Icon(
                icon,
                size: 25,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 8),

            // ----------------------------------------------------
            // VALEUR
            // ----------------------------------------------------

            Text(
              valeur.toString(),

              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // ----------------------------------------------------
            // TITRE
            // ----------------------------------------------------

            Text(
              titre,

              textAlign: TextAlign.center,

              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}