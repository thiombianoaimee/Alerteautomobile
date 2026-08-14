import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {

  const NotificationsScreen({super.key});


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

              color: Colors.blue,

              size: 80,

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