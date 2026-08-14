import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import 'creneaux_screen.dart';
import 'demandes_screen.dart';
import 'profil_garagiste_screen.dart';
import 'notification_garagiste_screen.dart';


class DashboardGaragisteScreen extends StatelessWidget {

  final UserModel user;


  const DashboardGaragisteScreen({
    super.key,
    required this.user,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(


        title: const Text(
          "Mon espace Garagiste",
        ),


        centerTitle: true,



        actions: [
          IconButton(

            icon: const Icon(
              Icons.notifications,
            ),

            tooltip: "Notifications",

            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const NotificationsGaragisteScreen(),
                ),
              );

            },

          ),


          // Profil Garagiste
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

                  builder: (context) => ProfilGaragisteScreen(
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

              "Gérez vos disponibilités et vos demandes de rendez-vous.",


              style: TextStyle(

                fontSize: 16,

              ),


            ),




            const SizedBox(height: 30),





            Expanded(


              child: ListView(


                children: [




                  _menuCard(

                    context,

                    Icons.schedule,

                    "Gérer mes disponibilités",

                    CreneauxScreen(
                      user: user,
                    ),
                    Colors.blue,

                  ),





                  _menuCard(

                    context,

                    Icons.calendar_month,

                    "Gérer les demandes de rendez-vous",

                    DemandesScreen(
                      user: user,
                    ),
                    Colors.green,

                  ),




                ],


              ),


            ),



          ],


        ),


      ),


    );


  }







  Widget _menuCard(


      BuildContext context,


      IconData icon,


      String title,


      Widget page,


      Color color,


      ){



    return TweenAnimationBuilder(


      duration: const Duration(milliseconds: 500),


      tween: Tween<double>(

        begin: 0,

        end: 1,

      ),



      builder: (context, value, child) {


        return Opacity(


          opacity: value,


          child: Transform.translate(


            offset: Offset(

              0,

              30 * (1 - value),

            ),


            child: child,


          ),


        );


      },





      child: InkWell(


        borderRadius: BorderRadius.circular(15),



        onTap: () {


          Navigator.push(


            context,


            MaterialPageRoute(


              builder: (context) => page,


            ),


          );


        },





        child: Card(


          elevation: 5,



          margin: const EdgeInsets.only(

            bottom: 15,

          ),




          shape: RoundedRectangleBorder(


            borderRadius: BorderRadius.circular(15),


          ),




          child: SizedBox(


            height: 85,



            child: Padding(


              padding: const EdgeInsets.all(15),



              child: Row(


                children: [



                  CircleAvatar(


                    radius: 25,


                    backgroundColor:
                    color.withValues(alpha: 0.15),



                    child: Icon(


                      icon,


                      size: 30,


                      color: color,


                    ),


                  ),

                  Expanded(

                    child: Text(

                      title,

                      maxLines: 2,

                      overflow: TextOverflow.ellipsis,


                      style: const TextStyle(

                        fontSize:18,

                        fontWeight:FontWeight.bold,

                      ),

                    ),

                  ),



                  const SizedBox(width: 20),







                  const Spacer(),





                  const Icon(


                    Icons.arrow_forward_ios,


                    size: 18,


                    color: Colors.grey,


                  ),




                ],


              ),


            ),


          ),


        ),


      ),


    );


  }


}