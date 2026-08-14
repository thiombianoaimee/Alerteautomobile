
import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
class ModifierEmailScreen extends StatefulWidget {
final UserModel user;

const ModifierEmailScreen({
super.key,
required this.user,
});

@override
State<ModifierEmailScreen> createState() =>
_ModifierEmailScreenState();
}

class _ModifierEmailScreenState extends State<ModifierEmailScreen> {
late TextEditingController _emailController;

@override
void initState() {
super.initState();

_emailController = TextEditingController(
text: widget.user.email,
);
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
title: const Text(
"Modifier mon email",
),
centerTitle: true,
),

body: Padding(
padding: const EdgeInsets.all(20),

child: Column(
crossAxisAlignment: CrossAxisAlignment.start,

children: [
const Text(
"Modifier mon adresse email",
style: TextStyle(
fontSize: 20,
fontWeight: FontWeight.bold,
),
),

const SizedBox(height: 25),

TextField(
controller: _emailController,
keyboardType: TextInputType.emailAddress,

decoration: InputDecoration(
labelText: "Nouvel email",
prefixIcon: const Icon(Icons.email),
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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final token = await StorageService.getToken();

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

    final nouvelEmail = _emailController.text.trim();

    if (nouvelEmail.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text("Veuillez saisir un email"),
        ),
      );
      return;
    }

    try {
      await ApiService.updateEmail(
        token,
        nouvelEmail,
      );

      if (!mounted) return;

      final utilisateurModifie = UserModel(
        id: widget.user.id,
        email: nouvelEmail,
        role: widget.user.role,
        nom: widget.user.nom,
        telephone: widget.user.telephone,
        adresse: widget.user.adresse,
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text("Email modifié avec succès"),
        ),
      );

      navigator.pop(utilisateurModifie);

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

