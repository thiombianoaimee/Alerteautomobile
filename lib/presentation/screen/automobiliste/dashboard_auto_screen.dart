import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import 'profil_auto_screen.dart';
import 'vehicules_screen.dart';
import 'notifications_screen.dart';
import 'rendezvous_screen.dart';
import 'suivi_auto_screen.dart';


class DashboardAutoScreen extends StatelessWidget {

  final UserModel user;


  const DashboardAutoScreen({
    super.key,
    required this.user,
  });



  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Mon suivi automobile",
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
                  const NotificationsScreen(),
                ),
              );

            },
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            tooltip: "Mon profil",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilAutoScreen(user: user),
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

              "Bienvenue, ${user.nom} ",

              style: const TextStyle(

                fontSize: 26,

                fontWeight: FontWeight.bold,

              ),

            ),




            const SizedBox(height:10),




            const Text(

              "Gérez vos véhicules et vos rendez-vous facilement.",


              style: TextStyle(

                fontSize:16,

              ),


            ),





            const SizedBox(height:30),






            Expanded(


              child: ListView(


                children: [



                  _menuCard(

                    context,

                    Icons.directions_car,

                    "Mes véhicules",

                    VehiculesScreen(
                      user: user,
                    ),

                    Colors.blue,

                  ),








                  _menuCard(

                    context,

                    Icons.calendar_month,

                    "Rendez-vous",

                    RendezVousScreen(
                      user: user,
                    )

                    ,Colors.green,

                  ),

                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                        ),
                      ),
                      title: const Text(
                        "Mon espace de suivi automobile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuiviAutomobilisteScreen(
                              user: user,
                            )
                          ),
                        );
                      },
                    ),
                  )






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


      {bool badge=false}


      ){





    return TweenAnimationBuilder(


      duration: const Duration(milliseconds:500),



      tween: Tween<double>(


        begin:0,


        end:1,


      ),




      builder:(context,value,child){



        return Opacity(


          opacity:value,



          child:Transform.translate(


            offset:Offset(0,30*(1-value)),



            child:child,



          ),


        );


      },





      child: InkWell(



        borderRadius:BorderRadius.circular(15),




        onTap:(){



          Navigator.push(


            context,


            MaterialPageRoute(


              builder:(context)=>page,


            ),


          );


        },





        child:Card(



          elevation:5,



          margin:const EdgeInsets.only(bottom:15),





          shape:RoundedRectangleBorder(


            borderRadius:BorderRadius.circular(15),


          ),






          child:SizedBox(



            height:85,






            child:Padding(



              padding:const EdgeInsets.all(15),





              child:Row(



                children:[





                  Stack(



                    children:[





                      CircleAvatar(



                        radius:25,



                        backgroundColor:
                        color.withValues(alpha: 0.15),



                        child:Icon(



                          icon,



                          size:30,



                          color:color,



                        ),



                      ),







                      if(badge)



                        Positioned(



                          right:0,



                          top:0,



                          child:Container(



                            width:15,



                            height:15,



                            decoration:const BoxDecoration(



                              color:Colors.red,



                              shape:BoxShape.circle,



                            ),



                          ),



                        ),





                    ],


                  ),





                  const SizedBox(width:20),





                  Text(



                    title,



                    style:const TextStyle(



                      fontSize:18,



                      fontWeight:FontWeight.bold,



                    ),



                  ),






                  const Spacer(),





                  const Icon(



                    Icons.arrow_forward_ios,



                    size:18,



                    color:Colors.grey,



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