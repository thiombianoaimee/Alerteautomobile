import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';
import 'automobilistes_admin_screen.dart';
import 'garagistes_admin_screen.dart';
import 'statistique_admin_screen.dart';
import 'config_alerte_screen.dart';
import 'gestion_abonnements_screen.dart';
import 'config_global_screen.dart';

class DashboardAdminScreen extends StatelessWidget {
  final UserModel user;

  const DashboardAdminScreen({
    super.key,
    required this.user,
  });

  Widget _adminProfileAvatar(BuildContext context, UserModel user) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilAdminScreen(user: user),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0, left: 5.0),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFF00838F),
          child: Text(
            user.nom.trim().isNotEmpty
                ? user.nom.trim()[0].toUpperCase()
                : 'A',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Espace Administrateur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          _adminProfileAvatar(context, user),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue, ${user.nom}",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Gestion et supervision de la plateforme.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _adminCard(
                    context,
                    icon: Icons.people,
                    title: "Comptes Utilisateurs",
                    color: Colors.blue,
                    page: DefaultTabController(
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text("Comptes Utilisateurs"),
                          actions: [_adminProfileAvatar(context, user)],
                          bottom: const TabBar(
                            tabs: [
                              Tab(text: "Automobilistes"),
                              Tab(text: "Garagistes"),
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: [
                            AutomobilistesAdminScreen(user: user, showAppBar: false),
                            GaragistesAdminScreen(user: user, showAppBar: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.bar_chart,
                    title: "Statistiques & Supervision",
                    color: Colors.green,
                    page: SupervisionAdminScreen(user: user),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.notifications_active,
                    title: "Configuration des Alertes",

                    color: Colors.purple,
                    page: DefaultTabController(
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text("Seuils d'Alertes"),
                          actions: [_adminProfileAvatar(context, user)],
                          bottom: const TabBar(
                            tabs: [
                              Tab(text: "Visite Techinique."),
                              Tab(text: "Abonnements"),
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: [
                            ConfigAlerteScreen(
                              user: user,
                              type: "visite_technique",
                              titre: "Alertes Visite",
                              description: "Rappels avant expiration de la visite technique.",
                              showAppBar: false,
                            ),
                            ConfigAlerteScreen(
                              user: user,
                              type: "abonnement",
                              titre: "Alertes Abonnement",
                              description: "Rappels avant expiration de l'abonnement.",
                              showAppBar: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.settings,
                    title: "Paramètres des Abonnements",

                    color: Colors.blueGrey,
                    page: DefaultTabController(
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text("Paramètres des Abonnements"),
                          actions: [_adminProfileAvatar(context, user)],
                          bottom: const TabBar(
                            tabs: [
                              Tab(text: "Période d'essai"),
                              Tab(text: "Plans & Tarifs"),
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: [
                            ConfigGlobalSubscriptionScreen(user: user, showAppBar: false),
                            GestionAbonnementsScreen(user: user, showAppBar: false),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _adminCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required Widget page,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 30,
            color: color,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: (subtitle != null && subtitle.trim().isNotEmpty)
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 18,
          color: color.withValues(alpha: 0.5),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => page,
            ),
          );
        },
      ),
    );
  }
}
