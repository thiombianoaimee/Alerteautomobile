import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../automobiliste/modifier_infos_screen.dart';
import '../../../profil/modifier_email_screen.dart';
import '../../../profil/modifier_mot_de_passe_screen.dart';

class ProfilAdminScreen extends StatefulWidget {

  final UserModel user;


  const ProfilAdminScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfilAdminScreen> createState() => _ProfilAdminScreenState();
}
class _ProfilAdminScreenState extends State<ProfilAdminScreen> {

  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(


      appBar: AppBar(

        title: const Text(
          "Mon profil Administrateur",
        ),

        centerTitle: true,

      ),




      body: Padding(

        padding: const EdgeInsets.all(20),


        child: Column(


          crossAxisAlignment: CrossAxisAlignment.center,


          children: [



            const CircleAvatar(

              radius: 45,

              child: Icon(

                Icons.admin_panel_settings,

                size: 50,

              ),

            ),




            const SizedBox(height: 25),




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

              ),

            ),




            const SizedBox(height: 30),





            _profileOption(

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

                if (!context.mounted) return;

                if (utilisateurModifie != null) {
                  setState(() {
                    user = utilisateurModifie;
                  });
                }
              },
            ),





            _profileOption(

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





            _profileOption(

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





            _profileOption(

              icon: Icons.logout,

              title: "Se déconnecter",

              onTap: () {


                Navigator.popUntil(

                  context,

                      (route) => route.isFirst,

                );


              },

            ),









          ],


        ),


      ),


    );


  }





  Widget _profileOption({

    required IconData icon,

    required String title,

    required VoidCallback onTap,

    Color color = Colors.black,

  }) {


    return Card(


      elevation: 3,


      margin: const EdgeInsets.only(

        bottom: 12,

      ),



      child: ListTile(


        leading: Icon(

          icon,

          color: color,

        ),



        title: Text(

          title,

          style: TextStyle(

            color: color,

            fontWeight: FontWeight.w500,

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