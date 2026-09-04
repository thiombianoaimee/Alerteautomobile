import 'package:flutter/material.dart';

import '../../../metier/models/user_model.dart';

import 'profil_admin_screen.dart';
import 'automobilistes_admin_screen.dart';
import 'garagistes_admin_screen.dart';
import 'statistique_admin_screen.dart';
import 'config_alerte_screen.dart';

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
                    title: "Gestion des automobilistes",
                    subtitle: "Consulter et gérer les comptes utilisateurs",
                    color: Colors.blue,
                    page: AutomobilistesAdminScreen(user: user),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.build,
                    title: "Gestion des garagistes",
                    subtitle: "Superviser les garages enregistrés",
                    color: Colors.orange,
                    page: GaragistesAdminScreen(user: user),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.bar_chart,
                    title: "Statistiques",
                    subtitle: "Analyser les activités de la plateforme",
                    color: Colors.green,
                    page: SupervisionAdminScreen(user: user),
                  ),
                  _adminCard(
                    context,
                    icon: Icons.notifications_active,
                    title: "Configuration des Alertes",
                    subtitle: "Paramétrer les dates et heures de rappel",
                    color: Colors.purple,
                    page: ConfigAlerteScreen(user: user),
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
