import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
final String token;

const ResetPasswordScreen({
super.key,
required this.token,
});

@override
State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
final TextEditingController _nouveauMotDePasseController =
TextEditingController();

final TextEditingController _confirmationController =
TextEditingController();

bool _isLoading = false;
bool _obscurePassword = true;
bool _obscureConfirmation = true;

Future<void> _reinitialiserMotDePasse() async {
final nouveauMotDePasse =
_nouveauMotDePasseController.text.trim();

final confirmation =
_confirmationController.text.trim();

if (nouveauMotDePasse.isEmpty || confirmation.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Veuillez remplir tous les champs.",
),
backgroundColor: Colors.red,
),
);
return;
}

if (nouveauMotDePasse.length < 8) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Le mot de passe doit contenir au moins 8 caractères.",
),
backgroundColor: Colors.red,
),
);
return;
}

if (nouveauMotDePasse != confirmation) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Les mots de passe ne correspondent pas.",
),
backgroundColor: Colors.red,
),
);
return;
}

setState(() {
_isLoading = true;
});

try {
await ApiService.resetPassword(
widget.token,
nouveauMotDePasse,
);

if (!mounted) return;

setState(() {
_isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Mot de passe réinitialisé avec succès.",
),
backgroundColor: Colors.green,
),
);

await Future.delayed(
const Duration(seconds: 1),
);

if (!mounted) return;

Navigator.pushNamedAndRemoveUntil(
context,
'/',
(route) => false,
);
} catch (e) {
if (!mounted) return;

setState(() {
_isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Erreur : ${e.toString().replaceFirst('Exception: ', '')}",
),
backgroundColor: Colors.red,
),
);
}
}

@override
void dispose() {
_nouveauMotDePasseController.dispose();
_confirmationController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text("Nouveau mot de passe"),
),
body: SingleChildScrollView(
padding: const EdgeInsets.all(25),
child: Column(
children: [
const SizedBox(height: 30),

const Icon(
Icons.lock_reset,
size: 80,
color: Color(0xFF1E88E5),
),

const SizedBox(height: 20),

const Text(
"Réinitialiser le mot de passe",
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

const Text(
"Saisissez votre nouveau mot de passe.",
textAlign: TextAlign.center,
style: TextStyle(
color: Colors.grey,
fontSize: 15,
),
),

const SizedBox(height: 30),

TextField(
controller: _nouveauMotDePasseController,
obscureText: _obscurePassword,
decoration: InputDecoration(
labelText: "Nouveau mot de passe",
prefixIcon: const Icon(Icons.lock_outline),
suffixIcon: IconButton(
icon: Icon(
_obscurePassword
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
onPressed: () {
setState(() {
_obscurePassword = !_obscurePassword;
});
},
),
border: const OutlineInputBorder(),
),
),

const SizedBox(height: 20),

TextField(
controller: _confirmationController,
obscureText: _obscureConfirmation,
decoration: InputDecoration(
labelText: "Confirmer le mot de passe",
prefixIcon: const Icon(Icons.lock_outline),
suffixIcon: IconButton(
icon: Icon(
_obscureConfirmation
? Icons.visibility_outlined
    : Icons.visibility_off_outlined,
),
onPressed: () {
setState(() {
_obscureConfirmation =
!_obscureConfirmation;
});
},
),
border: const OutlineInputBorder(),
),
),

const SizedBox(height: 30),

SizedBox(
width: double.infinity,
height: 50,
child: ElevatedButton(
onPressed: _isLoading
? null
    : _reinitialiserMotDePasse,
child: _isLoading
? const SizedBox(
width: 24,
height: 24,
child: CircularProgressIndicator(
color: Colors.white,
strokeWidth: 2,
),
)
    : const Text(
"RÉINITIALISER",
style: TextStyle(
fontWeight: FontWeight.bold,
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

