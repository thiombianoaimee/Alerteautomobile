import 'package:flutter/material.dart';

import '../../../metier/models/user_model.dart';

import 'profil_admin_screen.dart';
import 'automobilistes_admin_screen.dart';
import 'garagistes_admin_screen.dart';
import 'statistique_admin_screen.dart';
import 'rendezvous_admin_screen.dart';



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

                    subtitle:
                    "Consulter et gérer les comptes utilisateurs",

                    page: AutomobilistesAdminScreen(
                      user: user,
                    ),
                  ),




                  _adminCard(

                    context,

                    icon: Icons.build,

                    title: "Gestion des garagistes",

                    subtitle:
                    "Superviser les garages enregistrés",

                    page: GaragistesAdminScreen(
                      user: user,
                    ),
                  ),




                  _adminCard(

                    context,

                    icon: Icons.bar_chart,

                    title: "Statistiques",

                    subtitle:
                    "Analyser les activités de la plateforme",

                    page: SupervisionAdminScreen(
                      user: user,
                    ),
                  ),





                  _adminCard(

                    context,

                    icon: Icons.calendar_month,

                    title: "Gestion des rendez-vous",

                    subtitle:
                    "Suivre les rendez-vous des utilisateurs",

                    page: RendezVousAdminScreen(
                      user: user,
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

      }) {



    return Card(


      elevation: 5,


      margin: const EdgeInsets.only(bottom: 18),



      shape: RoundedRectangleBorder(

        borderRadius: BorderRadius.circular(15),

      ),





      child: ListTile(


        contentPadding: const EdgeInsets.all(15),




        leading: CircleAvatar(


          radius: 25,


          child: Icon(

            icon,

            size: 28,

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

          style: const TextStyle(

            fontSize: 14,

          ),

        ),




        trailing: const Icon(

          Icons.arrow_forward_ios,

          size: 18,

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