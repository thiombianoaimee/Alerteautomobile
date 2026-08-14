import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';

class SupervisionAdminScreen extends StatelessWidget {

  final UserModel user;

  const SupervisionAdminScreen({
    super.key,
    required this.user,
  });


  @override
  Widget build(BuildContext context){

    return Scaffold(

      appBar: AppBar(
        title: const Text("Supervision"),

        actions: [
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

      body: const Center(

        child: Text(
          "Tableau de supervision",
        ),

      ),

    );

  }

}