import 'package:flutter/material.dart';

class NotificationsGaragisteScreen extends StatelessWidget {

  const NotificationsGaragisteScreen({super.key});


  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Notifications",
        ),

        centerTitle: true,

      ),



      body: Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,


          children: [


            const Icon(

              Icons.notifications,

              size: 80,

              color: Colors.blue,

            ),



            const SizedBox(height: 20),



            const Text(

              "Aucune notification",

              style: TextStyle(

                fontSize: 20,

                fontWeight: FontWeight.bold,

              ),

            ),


          ],

        ),

      ),

    );

  }

}