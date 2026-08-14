import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';


class ModifierInfosScreen extends StatefulWidget {
final UserModel user;

const ModifierInfosScreen({
super.key,
required this.user,
});

@override
State<ModifierInfosScreen> createState() => _ModifierInfosScreenState();
}

class _ModifierInfosScreenState extends State<ModifierInfosScreen> {
late TextEditingController _nomController;
late TextEditingController _telephoneController;
late TextEditingController _adresseController;

@override
void initState() {
super.initState();

_nomController = TextEditingController(text: widget.user.nom);
_telephoneController =
TextEditingController(text: widget.user.telephone);
_adresseController =
TextEditingController(text: widget.user.adresse);
}

@override
void dispose() {
_nomController.dispose();
_telephoneController.dispose();
_adresseController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Modifier mes informations"),
centerTitle: true,
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
"Mes informations personnelles",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 25),

TextField(
controller: _nomController,
decoration: InputDecoration(
labelText: "Nom",
prefixIcon: const Icon(Icons.person),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),

const SizedBox(height: 20),

TextField(
controller: _telephoneController,
keyboardType: TextInputType.phone,
decoration: InputDecoration(
labelText: "Téléphone",
prefixIcon: const Icon(Icons.phone),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),

const SizedBox(height: 20),

TextField(
controller: _adresseController,
decoration: InputDecoration(
labelText: "Adresse",
prefixIcon: const Icon(Icons.location_on),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),

const SizedBox(height: 35),

SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton(

  onPressed: () async {

    final token = await StorageService.getToken();

    if (!context.mounted) return;

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Session expirée, veuillez vous reconnecter"),
        ),
      );
      return;
    }

    try {
      await ApiService.updateProfile(
        token,
        {
          "nom": _nomController.text.trim(),
          "telephone": _telephoneController.text.trim(),
          "adresse": _adresseController.text.trim(),
        },
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Informations modifiées avec succès"),
        ),
      );

      final utilisateurModifie = UserModel(
        id: widget.user.id,
        email: widget.user.email,
        role: widget.user.role,
        nom: _nomController.text.trim(),
        telephone: _telephoneController.text.trim(),
        adresse: _adresseController.text.trim(),
      );
      Navigator.pop(context, utilisateurModifie);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
        ),
      );
    }
  },



child: const Text(
"Enregistrer",
style: TextStyle(fontSize: 16),
),
),
),
],
),
),
);
}
}

