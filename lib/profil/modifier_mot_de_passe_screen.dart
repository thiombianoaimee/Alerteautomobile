
import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class ChangerMotDePasseScreen extends StatefulWidget {
final UserModel user;

const ChangerMotDePasseScreen({
super.key,
required this.user,
});

@override
State<ChangerMotDePasseScreen> createState() =>
_ChangerMotDePasseScreenState();
}

class _ChangerMotDePasseScreenState
extends State<ChangerMotDePasseScreen> {
final TextEditingController _ancienMotDePasseController =
TextEditingController();

final TextEditingController _nouveauMotDePasseController =
TextEditingController();

final TextEditingController _confirmationController =
TextEditingController();

bool _ancienVisible = false;
bool _nouveauVisible = false;
bool _confirmationVisible = false;

@override
void dispose() {
_ancienMotDePasseController.dispose();
_nouveauMotDePasseController.dispose();
_confirmationController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Changer le mot de passe"),
centerTitle: true,
),

body: SingleChildScrollView(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [
const Text(
"Modifier mon mot de passe",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 25),

// Ancien mot de passe
TextField(
controller: _ancienMotDePasseController,
obscureText: !_ancienVisible,

decoration: InputDecoration(
labelText: "Ancien mot de passe",
prefixIcon: const Icon(Icons.lock),

suffixIcon: IconButton(
icon: Icon(
_ancienVisible
? Icons.visibility
    : Icons.visibility_off,
),
onPressed: () {
setState(() {
_ancienVisible = !_ancienVisible;
});
},
),

border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),

const SizedBox(height: 20),

// Nouveau mot de passe
TextField(
controller: _nouveauMotDePasseController,
obscureText: !_nouveauVisible,

decoration: InputDecoration(
labelText: "Nouveau mot de passe",
prefixIcon: const Icon(Icons.lock_outline),

suffixIcon: IconButton(
icon: Icon(
_nouveauVisible
? Icons.visibility
    : Icons.visibility_off,
),
onPressed: () {
setState(() {
_nouveauVisible = !_nouveauVisible;
});
},
),

border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),

const SizedBox(height: 20),

// Confirmation du nouveau mot de passe
TextField(
controller: _confirmationController,
obscureText: !_confirmationVisible,

decoration: InputDecoration(
labelText: "Confirmer le nouveau mot de passe",
prefixIcon: const Icon(Icons.lock_outline),

suffixIcon: IconButton(
icon: Icon(
_confirmationVisible
? Icons.visibility
    : Icons.visibility_off,
),
onPressed: () {
setState(() {
_confirmationVisible =
!_confirmationVisible;
});
},
),

border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
),
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 50,

child: ElevatedButton(
onPressed: () async {
final messenger =
ScaffoldMessenger.of(context);

final navigator =
Navigator.of(context);

final ancienMotDePasse =
_ancienMotDePasseController.text.trim();

final nouveauMotDePasse =
_nouveauMotDePasseController.text.trim();

final confirmation =
_confirmationController.text.trim();

// Vérifier que tous les champs sont remplis
if (ancienMotDePasse.isEmpty ||
nouveauMotDePasse.isEmpty ||
confirmation.isEmpty) {
messenger.showSnackBar(
const SnackBar(
content: Text(
"Veuillez remplir tous les champs",
),
),
);
return;
}

// Vérifier la confirmation
if (nouveauMotDePasse != confirmation) {
messenger.showSnackBar(
const SnackBar(
content: Text(
"Les nouveaux mots de passe ne correspondent pas",
),
),
);
return;
}

// Récupérer le token
final token =
await StorageService.getToken();

if (!mounted) return;

if (token == null) {
messenger.showSnackBar(
const SnackBar(
content: Text(
"Session expirée, veuillez vous reconnecter",
),
),
);
return;
}

try {
// Appel du backend
await ApiService.updatePassword(
token,
ancienMotDePasse,
nouveauMotDePasse,
);

if (!mounted) return;

messenger.showSnackBar(
const SnackBar(
content: Text(
"Mot de passe modifié avec succès",
),
),
);

// Retour au profil
navigator.pop();
} catch (e) {
if (!mounted) return;

messenger.showSnackBar(
SnackBar(
content: Text("Erreur : $e"),
),
);
}
},

child: const Text(
"Enregistrer",
style: TextStyle(
fontSize: 16,
),
),
),
),
],
),
),
);
}
}

