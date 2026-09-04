import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';

class MotDePasseOublieScreen extends StatefulWidget {
const MotDePasseOublieScreen({super.key});

@override
State<MotDePasseOublieScreen> createState() =>
_MotDePasseOublieScreenState();
}

class _MotDePasseOublieScreenState
extends State<MotDePasseOublieScreen> {

final TextEditingController _emailController =
TextEditingController();

bool _isLoading = false;
bool _emailEnvoye = false;

Future<void> _demanderReinitialisation() async {
final email = _emailController.text.trim();

if (email.isEmpty) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text("Veuillez saisir votre adresse e-mail"),
),
);
return;
}

setState(() {
_isLoading = true;
});

try {
await ApiService.requestPasswordReset(email);

if (!mounted) return;

setState(() {
_isLoading = false;
_emailEnvoye = true;
});

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Un lien de réinitialisation a été envoyé à votre e-mail.",
),
backgroundColor: Colors.green,
),
);

} catch (e) {

if (!mounted) return;

setState(() {
_isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text("Erreur : $e"),
backgroundColor: Colors.red,
),
);
}
}

@override
void dispose() {
_emailController.dispose();
super.dispose();
}

@override
Widget build(BuildContext context) {

return Scaffold(
appBar: AppBar(
title: const Text("Récupération du compte"),
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

Text(
_emailEnvoye
? "E-mail envoyé"
    : "Mot de passe oublié ?",
style: const TextStyle(
fontSize: 22,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 15),

Text(
_emailEnvoye
? "Consultez votre boîte e-mail et cliquez sur le lien reçu pour créer un nouveau mot de passe."
    : "Entrez votre adresse e-mail pour recevoir un lien de réinitialisation.",
textAlign: TextAlign.center,
style: const TextStyle(
color: Colors.grey,
fontSize: 15,
),
),

const SizedBox(height: 30),

if (!_emailEnvoye) ...[

TextField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,

decoration: const InputDecoration(
labelText: "Votre adresse e-mail",
hintText: "exemple@gmail.com",
prefixIcon: Icon(Icons.email_outlined),
border: OutlineInputBorder(),
),
),

const SizedBox(height: 25),

SizedBox(
width: double.infinity,
height: 50,

child: ElevatedButton(
onPressed:
_isLoading
? null
    : _demanderReinitialisation,

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
"ENVOYER LE LIEN",
style: TextStyle(
fontWeight: FontWeight.bold,
),
),
),
),

] else ...[

const Icon(
Icons.mark_email_read_outlined,
size: 60,
color: Colors.green,
),

const SizedBox(height: 20),

const Text(
"Vérifiez votre boîte de réception.\n\n"
"Un lien de réinitialisation vous a été envoyé. "
"Ce lien est valable pendant une heure.",
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 15,
),
),

const SizedBox(height: 25),

TextButton(
onPressed: _isLoading
? null
    : () {
setState(() {
_emailEnvoye = false;
});
},
child: const Text(
"Renvoyer le lien",
),
),
],
],
),
),
);
}
}

