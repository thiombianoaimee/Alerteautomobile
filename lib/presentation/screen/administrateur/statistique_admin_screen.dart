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
  State<SupervisionAdminScreen> createState() => _SupervisionAdminScreenState();
}

class _SupervisionAdminScreenState extends State<SupervisionAdminScreen> {
  Map<String, dynamic>? statistiques;
  Map<String, dynamic>? statsAbonnements;
  bool chargement = true;
  String? erreur;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    chargerDonnees();
  }

  Future<void> chargerDonnees() async {
    try {
      setState(() {
        chargement = true;
        erreur = null;
      });

      final token = await StorageService.getToken();
      if (token == null) throw Exception("Token introuvable");

      // On charge les deux types de stats en parallèle
      final resultats = await Future.wait([
        ApiService.getStatistiques(token),
        ApiService.getAbonnementsStatistiques(token),
      ]);

      if (!mounted) return;

      setState(() {
        statistiques = resultats[0];
        statsAbonnements = resultats[1];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Supervision Générale"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: chargerDonnees,
          ),
        ],
      ),
      body: _construireContenu(),
    );
  }

  Widget _construireContenu() {
    if (chargement) return const Center(child: CircularProgressIndicator());
    if (erreur != null) return _buildErrorView();
    if (statistiques == null) return const Center(child: Text("Aucune donnée disponible"));

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _pageTab("Utilisateurs", 0),
                const SizedBox(width: 15),
                _pageTab("Véhicules", 1),
                const SizedBox(width: 15),
                _pageTab("Rendez-vous", 2),
                const SizedBox(width: 15),
                _pageTab("Abonnements", 3),
              ],
            ),
          ),
        ),
        
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentPage = index),
            children: [
              // Onglet 0 : Utilisateurs
              _buildCategoryPage("Utilisateurs", Icons.people, [
                _statItem("Automobilistes", statistiques!["utilisateurs"]["automobilistes"], Icons.person, Colors.blue),
                _statItem("Garagistes", statistiques!["utilisateurs"]["garagistes"], Icons.build, Colors.orange),
                _statItem("Comptes actifs", statistiques!["utilisateurs"]["comptesActifs"], Icons.check_circle, Colors.green),
                _statItem("Comptes désactivés", statistiques!["utilisateurs"]["comptesDesactives"], Icons.cancel, Colors.red),
              ]),
              // Onglet 1 : Véhicules
              _buildCategoryPage("Véhicules", Icons.directions_car, [
                _statItem("Total véhicules", statistiques!["vehicules"], Icons.directions_car, Colors.blue),
              ]),
              // Onglet 2 : RDV
              _buildCategoryPage("Rendez-vous", Icons.calendar_month, [
                _statItem("Total", statistiques!["rendezVous"]["total"], Icons.calendar_month, Colors.blue),
                _statItem("Confirmés", statistiques!["rendezVous"]["confirmes"], Icons.check_circle, Colors.green),
                _statItem("En attente", statistiques!["rendezVous"]["enAttente"], Icons.hourglass_empty, Colors.orange),
                _statItem("Annulés", statistiques!["rendezVous"]["annules"], Icons.cancel, Colors.red),
              ]),
              // Onglet 3 : Abonnements (NOUVEAU)
              _buildCategoryPage("Abonnements", Icons.card_membership, [
                _statItem("Total abonnés", statsAbonnements?["total"] ?? 0, Icons.people_alt, Colors.teal),
                _statItem("Premium", statsAbonnements?["premium"] ?? 0, Icons.star, Colors.orange),
                _statItem("Basic", statsAbonnements?["basic"] ?? 0, Icons.star_border, Colors.blueGrey),
                _statItem("En période d'essai", statsAbonnements?["essai"] ?? 0, Icons.timer, Colors.blue),
              ]),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageTab(String title, int index) {
    bool isActive = _currentPage == index;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? Colors.blue : Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            height: 3,
            width: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.blue : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCategoryPage(String title, IconData icon, List<Widget> items) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(icon, size: 60, color: Colors.blue.withValues(alpha: 0.2)),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: items,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statItem(String titre, dynamic valeur, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 8),
            FittedBox(
              child: Text(
                valeur.toString(),
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              titre,
              textAlign: TextAlign.center,
              maxLines: 2,
              style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 15),
          Text(erreur!, textAlign: TextAlign.center),
          ElevatedButton(onPressed: chargerDonnees, child: const Text("Réessayer")),
        ],
      ),
    );
  }
}
