import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';
import 'automobilistes_admin_screen.dart';
import 'garagistes_admin_screen.dart';
import 'statistique_admin_screen.dart';
import 'config_alerte_screen.dart';
import 'gestion_abonnements_screen.dart';
import 'config_global_screen.dart';
import 'abonnements_admin_screen.dart';

class DashboardAdminScreen extends StatelessWidget {

  final UserModel user;


  const DashboardAdminScreen({
    super.key,
    required this.user,
  });



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



          // Profil administrateur
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
                    user: user,
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
                    subtitle: "Gérer les automobilistes et garagistes",
                    color: Colors.blue,
                    page: AutomobilistesAdminScreen(user: user), // Tu peux alterner ou créer une vue liste simple
                  ),
                  _adminCard(
                    context,
                    icon: Icons.bar_chart,
                    title: "Statistiques & Supervision",
                    subtitle: "Activités, véhicules et abonnements",
                    color: Colors.green,
                    page: SupervisionAdminScreen(user: user),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.notifications_active,
                    title: "Configuration des Alertes",
                    subtitle: "Seuils visite technique et abonnements",
                    color: Colors.purple,
                    page: DefaultTabController(
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text("Seuils d'Alertes"),
                          bottom: const TabBar(
                            tabs: [
                              Tab(text: "Visite Technique"),
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
                            ),
                            ConfigAlerteScreen(
                              user: user,
                              type: "abonnement",
                              titre: "Alertes Abonnement",
                              description: "Rappels avant expiration de l'abonnement.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.settings,
                    title: "Paramètres Système",
                    subtitle: "Plans, tarifs et période d'essai",
                    color: Colors.blueGrey,
                    page: DefaultTabController(
                      length: 2,
                      child: Scaffold(
                        appBar: AppBar(
                          title: const Text("Paramètres"),
                          bottom: const TabBar(
                            tabs: [
                              Tab(text: "Plans & Tarifs"),
                              Tab(text: "Global"),
                            ],
                          ),
                        ),
                        body: TabBarView(
                          children: [
                            GestionAbonnementsScreen(user: user),
                            ConfigGlobalSubscriptionScreen(user: user),
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
    required String subtitle,
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
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
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
