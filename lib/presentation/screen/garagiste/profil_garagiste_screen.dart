import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../automobiliste/modifier_infos_screen.dart';
import '../../../profil/modifier_email_screen.dart';
import '../../../profil/modifier_mot_de_passe_screen.dart';
import '../../../profil/supprimer_son_compte_screen.dart';
class ProfilGaragisteScreen extends StatefulWidget {

  final UserModel user;


  const ProfilGaragisteScreen({
    super.key,
    required this.user,
  });

  @override
  State<ProfilGaragisteScreen> createState() =>
      _ProfilGaragisteScreenState();

}

class _ProfilGaragisteScreenState
    extends State<ProfilGaragisteScreen> {

  late UserModel user;

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context)  {

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

              radius: 45,

              child: Icon(
                Icons.build,
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



            Card(

              child: ListTile(

                leading: const Icon(Icons.edit),

                title: const Text(
                  "Modifier mes informations",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
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

            ),



            Card(

              child: ListTile(

                leading: const Icon(Icons.email),

                title: const Text(
                  "Modifier mon email",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),

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

            ),



            Card(

              child: ListTile(

                leading: const Icon(Icons.lock),

                title: const Text(
                  "Changer le mot de passe",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),

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

            ),



            Card(

              child: ListTile(

                leading: const Icon(Icons.logout),

                title: const Text(
                  "Se déconnecter",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),

                onTap: () {

                  Navigator.popUntil(
                    context,
                        (route) => route.isFirst,
                  );

                },

              ),

            ),



            Card(

              child: ListTile(

                leading: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),

                title: const Text(
                  "Supprimer le compte",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),

                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SupprimerCompteScreen(
                        user: user,
                      ),
                    ),
                  );
                },

              ),

            ),


          ],

        ),

      ),

    );

  }

}