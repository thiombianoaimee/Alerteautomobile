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
  bool chargement = true;
  String? erreur;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    chargerStatistiques();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> chargerStatistiques() async {
    try {
      setState(() {
        chargement = true;
        erreur = null;
      });

      final token = await StorageService.getToken();
      if (token == null) throw Exception("Token introuvable");

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Supervision"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: chargerStatistiques,
          ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilAdminScreen(user: widget.user)),
              );
            },
          ),
        ],
      ),
      body: _construireContenu(),
    );
  }

  Widget _construireContenu() {
    if (chargement) return const Center(child: CircularProgressIndicator());
    if (erreur != null) return _buildErrorView();
    if (statistiques == null) return const Center(child: Text("Aucune statistique disponible"));

    return Column(
      children: [
        // Indicateur de page en haut
        Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _pageTab("Utilisateurs", 0),
              _pageTab("Véhicules", 1),
              _pageTab("Rendez-vous", 2),
            ],
          ),
        ),
        
        // Corps coulissant horizontalement
        Expanded(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            children: [
              _buildCategoryPage(
                "Utilisateurs",
                Icons.people,
                [
                  _statItem("Automobilistes", statistiques!["utilisateurs"]["automobilistes"], Icons.person, Colors.blue),
                  _statItem("Garagistes", statistiques!["utilisateurs"]["garagistes"], Icons.build, Colors.orange),
                  _statItem("Comptes actifs", statistiques!["utilisateurs"]["comptesActifs"], Icons.check_circle, Colors.green),
                  _statItem("Comptes désactivés", statistiques!["utilisateurs"]["comptesDesactives"], Icons.cancel, Colors.red),
                ],
              ),
              _buildCategoryPage(
                "Véhicules",
                Icons.directions_car,
                [
                  _statItem("Total véhicules", statistiques!["vehicules"], Icons.directions_car, Colors.blue),
                ],
              ),
              _buildCategoryPage(
                "Rendez-vous",
                Icons.calendar_month,
                [
                  _statItem("Total", statistiques!["rendezVous"]["total"], Icons.calendar_month, Colors.blue),
                  _statItem("Confirmés", statistiques!["rendezVous"]["confirmes"], Icons.check_circle, Colors.green),
                  _statItem("En attente", statistiques!["rendezVous"]["enAttente"], Icons.hourglass_empty, Colors.orange),
                  _statItem("Annulés", statistiques!["rendezVous"]["annules"], Icons.cancel, Colors.red),
                ],
              ),
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
          ElevatedButton(onPressed: chargerStatistiques, child: const Text("Réessayer")),
        ],
      ),
    );
  }
}
