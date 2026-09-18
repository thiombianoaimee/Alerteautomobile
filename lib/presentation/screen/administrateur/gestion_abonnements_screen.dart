import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/storage_service.dart';

class GestionAbonnementsScreen extends StatefulWidget {
final UserModel user;

const GestionAbonnementsScreen({
super.key,
required this.user,
});

@override
State<GestionAbonnementsScreen> createState() =>
_GestionAbonnementsScreenState();
}

class _GestionAbonnementsScreenState
extends State<GestionAbonnementsScreen> {
List<dynamic> _plans = [];
bool _isLoading = true;

@override
void initState() {
super.initState();
_fetchPlans();
}

// ==========================================================
// RÉCUPÉRER LES PLANS
// ==========================================================

Future<void> _fetchPlans() async {
  try {
    final token = await StorageService.getToken();

    if (token == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final plans = await ApiService.getSubscriptionPlans(token);

    // Filtre pour exclure Pro/Elite
    final plansFiltres = plans.where((plan) {
      final String nom = (plan['nom'] ?? '').toString().toLowerCase();
      return !nom.contains("pro") && !nom.contains("elite");
    }).toList();

    setState(() {
      _plans = plansFiltres;
      _isLoading = false;
    });
  } catch (e) {
    debugPrint("Erreur récupération plans : $e");

    setState(() {
      _plans = [];
      _isLoading = false;
    });
  }
}

// ==========================================================
// MODIFIER UN PLAN
// ==========================================================

void _editPlan(dynamic plan) {
  if (plan == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "La création de nouveaux plans se fait via l'API pour l'instant",
        ),
      ),
    );
    return;
  }

  _showEditPlanDialog(plan);
}

// ==========================================================
// COULEUR SELON L'ORDRE DU PLAN
// ==========================================================

Color _colorForOrdre(int ordre) {
  switch (ordre) {
    case 1:
      return Colors.grey;

    case 2:
      return Colors.blue;

    default:
      return Colors.blueGrey;
  }
}

// ==========================================================
// AFFICHAGE DE LA PÉRIODE
// ==========================================================

String _labelPeriode(String? periode) {
switch (periode) {
case "semestriel":
return "/ 6 mois";

case "annuel":
return "/ an";

default:
return "";
}
}

// ==========================================================
// DIALOGUE MODIFICATION PLAN
// ==========================================================

void _showEditPlanDialog(dynamic plan) {
final prixController = TextEditingController(
text: plan['prix'].toString(),
);

final descriptionController = TextEditingController(
text: plan['description'] ?? '',
);

bool isSaving = false;

showDialog(
context: context,
builder: (context) {
return StatefulBuilder(
builder: (context, setDialogState) {
return AlertDialog(
title: Text(
"Modifier ${plan['nomAffiche'] ?? plan['nom']}",
),

content: Column(
mainAxisSize: MainAxisSize.min,
children: [
// PRIX
TextField(
controller: prixController,
keyboardType: TextInputType.number,
decoration: const InputDecoration(
labelText: "Prix (FCFA)",
border: OutlineInputBorder(),
),
),

const SizedBox(height: 15),

// DESCRIPTION
TextField(
controller: descriptionController,
maxLines: 2,
decoration: const InputDecoration(
labelText: "Description",
border: OutlineInputBorder(),
),
),
],
),

actions: [
// ANNULER
TextButton(
onPressed: isSaving
? null
    : () => Navigator.pop(context),
child: const Text("Annuler"),
),

// ENREGISTRER
ElevatedButton(
onPressed: isSaving
? null
    : () async {
final prix = int.tryParse(
prixController.text.trim(),
);

if (prix == null) {
ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
"Prix invalide",
),
),
);
return;
}

setDialogState(() {
isSaving = true;
});

try {
final token =
await StorageService.getToken();

if (token == null) return;

await ApiService.updateSubscriptionPlan(
token,
plan['_id'],
{
"prix": prix,
"description":
descriptionController.text
    .trim(),
},
);

if (context.mounted) {
Navigator.pop(context);

ScaffoldMessenger.of(context)
    .showSnackBar(
const SnackBar(
content: Text(
"Plan modifié avec succès",
),
backgroundColor:
Colors.green,
),
);
}

_fetchPlans();
} catch (e) {
setDialogState(() {
isSaving = false;
});

if (context.mounted) {
ScaffoldMessenger.of(context)
    .showSnackBar(
SnackBar(
content: Text(
"Erreur : $e",
),
),
);
}
}
},

child: isSaving
? const SizedBox(
width: 20,
height: 20,
child:
CircularProgressIndicator(
strokeWidth: 2,
color: Colors.white,
),
)
    : const Text("Enregistrer"),
),
],
);
},
);
},
);
}

// ==========================================================
// INTERFACE
// ==========================================================

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
"Paliers d'Abonnement",
),

actions: [
IconButton(
icon: const Icon(Icons.add),
onPressed: () => _editPlan(null),
),
],
),

body: _isLoading
? const Center(
child: CircularProgressIndicator(),
)
    : _plans.isEmpty
? const Center(
child: Text(
"Aucun abonnement disponible.",
style: TextStyle(
fontSize: 16,
),
),
)
    : ListView.builder(
padding: const EdgeInsets.all(16),
itemCount: _plans.length,

itemBuilder: (context, index) {
final plan = _plans[index];

final List fonctionnalites =
plan['fonctionnalites'] ?? [];

final Color color =
_colorForOrdre(
plan['ordre'] ?? 0,
);

final String periode =
(plan['periodeFacturation'] ?? '')
    .toString();

return Card(
margin:
const EdgeInsets.only(
bottom: 16,
),

shape:
RoundedRectangleBorder(
borderRadius:
BorderRadius.circular(15),
),

elevation: 4,

child: ExpansionTile(
// ==================================================
// ICÔNE
// ==================================================

leading: CircleAvatar(
backgroundColor:
color.withValues(
alpha: 0.1,
),

child: Icon(
Icons.star,
color: color,
),
),

// ==================================================
// NOM DU PLAN
// ==================================================

title: Text(
plan['nomAffiche'] ??
plan['nom'] ??
'',

style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 18,
),
),

// ==================================================
// PRIX + PÉRIODE
// ==================================================

subtitle: Text(
"${plan['prix']} FCFA ${_labelPeriode(periode)}",

style:
TextStyle(
color: color,
fontWeight:
FontWeight.bold,
),
),

// ==================================================
// DÉTAILS
// ==================================================

children: [
Padding(
padding:
const EdgeInsets.all(
16.0,
),

child: Column(
crossAxisAlignment:
CrossAxisAlignment
    .start,

children: [
// ==========================================
// FONCTIONNALITÉS
// ==========================================

const Text(
"Fonctionnalités incluses :",

style:
TextStyle(
fontWeight:
FontWeight.bold,
),
),

const SizedBox(
height: 8,
),

Wrap(
spacing: 8,

runSpacing: 8,

children:
fonctionnalites
    .map(
(f) {
return Chip(
label: Text(
(f['nom'] ??
f['cle'] ??
'')
    .toString()
    .toUpperCase(),

style:
const TextStyle(
fontSize: 10,
),
),

backgroundColor:
Colors.grey[
200],
);
},
).toList(),
),

const Divider(),

// ==========================================
// BOUTONS
// ==========================================

Row(
mainAxisAlignment:
MainAxisAlignment
    .end,

children: [
// MODIFIER
TextButton.icon(
onPressed: () =>
_editPlan(
plan,
),

icon:
const Icon(
Icons.edit,
),

label:
const Text(
"Modifier",
),
),

// SUPPRIMER
TextButton.icon(
onPressed: () {},

icon:
const Icon(
Icons.delete,
color:
Colors.red,
),

label:
const Text(
"Supprimer",
style:
TextStyle(
color:
Colors.red,
),
),
),
],
),
],
),
),
],
),
);
},
),
);
}
}

