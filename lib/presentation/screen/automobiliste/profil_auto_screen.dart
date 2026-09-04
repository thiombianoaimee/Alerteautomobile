import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import 'modifier_infos_screen.dart';
import '../../../profil/modifier_email_screen.dart';
import '../../../profil/modifier_mot_de_passe_screen.dart';

class ProfilAutoScreen extends StatefulWidget {

  final UserModel user;



  const ProfilAutoScreen({

    super.key,

    required this.user,

  });

  @override State<ProfilAutoScreen> createState() => _ProfilAutoScreenState(); } class _ProfilAutoScreenState extends State<ProfilAutoScreen> { late UserModel user; @override void initState() { super.initState(); user = widget.user; }



  @override
  Widget build(BuildContext context) {


    return Scaffold(



      appBar: AppBar(


        title: const Text(

          "Mon profil",

        ),


        centerTitle: true,


      ),





      body: Padding(


        padding: const EdgeInsets.all(20),



        child: Column(


          crossAxisAlignment: CrossAxisAlignment.center,



          children: [





            const CircleAvatar(


              radius: 50,


              child: Icon(


                Icons.person,


                size: 55,


              ),


            ),





            const SizedBox(height: 20),






            Text(


              user.nom,


              style: const TextStyle(


                fontSize: 24,


                fontWeight: FontWeight.bold,


              ),


            ),





            const SizedBox(height: 10),





            Text(


              user.email,


              style: const TextStyle(


                fontSize: 16,


                color: Colors.grey,


              ),


            ),





            const SizedBox(height: 35),





            _profilOption(


              icon: Icons.edit,


              title: "Modifier mes informations",

              onTap: () async {

                final UserModel? utilisateurModifie =
                await Navigator.push<UserModel>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifierInfosScreen(
                      user: user,
                    ),
                  ),
                );

                if (utilisateurModifie != null) {
                  setState(() {
                    user = utilisateurModifie;
                  });
                }

              },



            ),






            const SizedBox(height: 10),





            _profilOption(


              icon: Icons.email,


              title: "Modifier mon email",

              onTap: () async {
                final UserModel? utilisateurModifie =
                await Navigator.push<UserModel>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ModifierEmailScreen(
                      user: user,
                    ),
                  ),
                );

                if (utilisateurModifie != null) {
                  setState(() {
                    user = utilisateurModifie;
                  });
                }
              },


            ),






            const SizedBox(height: 10),





            _profilOption(


              icon: Icons.lock,


              title: "Changer le mot de passe",

              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ChangerMotDePasseScreen(
                      user: user,
                    ),
                  ),
                );
              },



            ),






            const SizedBox(height: 10),





            _profilOption(


              icon: Icons.logout,


              title: "Se déconnecter",


              onTap: () {


                Navigator.popUntil(


                  context,


                      (route) => route.isFirst,


                );


              },


            ),






            const SizedBox(height: 10),










          ],


        ),


      ),



    );


  }








  Widget _profilOption({


    required IconData icon,


    required String title,


    required VoidCallback onTap,


    Color color = Colors.black,


  }) {



    return Card(



      elevation: 4,



      shape: RoundedRectangleBorder(


        borderRadius: BorderRadius.circular(15),


      ),





      child: ListTile(



        contentPadding: const EdgeInsets.symmetric(


          horizontal: 20,


          vertical: 5,


        ),





        leading: Icon(


          icon,


          color: color,


          size: 28,


        ),





        title: Text(


          title,


          style: TextStyle(


            fontSize: 16,


            fontWeight: FontWeight.w600,


            color: color,


          ),


        ),





        trailing: const Icon(


          Icons.arrow_forward_ios,


          size: 18,


        ),





        onTap: onTap,



      ),


    );


  }


}