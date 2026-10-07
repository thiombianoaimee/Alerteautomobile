import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/storage_service.dart';
import 'profil_admin_screen.dart';

class GestionAbonnementsScreen extends StatefulWidget {
  final UserModel user;
  final bool showAppBar;

  const GestionAbonnementsScreen({
    super.key,
    required this.user,
    this.showAppBar = true,
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
    Widget content = _isLoading
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

                  final List fonctionnalites = plan['fonctionnalites'] ?? [];

                  final Color color = _colorForOrdre(
                    plan['ordre'] ?? 0,
                  );

                  final String periode = (plan['periodeFacturation'] ?? '').toString();

                  return Card(
                    margin: const EdgeInsets.only(
                      bottom: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: ExpansionTile(
                      leading: CircleAvatar(
                        backgroundColor: color.withValues(
                          alpha: 0.1,
                        ),
                        child: Icon(
                          Icons.star,
                          color: color,
                        ),
                      ),
                      title: Text(
                        plan['nomAffiche'] ?? plan['nom'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text(
                        "${plan['prix']} FCFA ${_labelPeriode(periode)}",
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(
                            16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Fonctionnalités incluses :",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 8,
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: fonctionnalites.map(
                                  (f) {
                                    return Chip(
                                      label: Text(
                                        (f['nom'] ?? f['cle'] ?? '').toString().toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                      backgroundColor: Colors.grey[200],
                                    );
                                  },
                                ).toList(),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _editPlan(
                                      plan,
                                    ),
                                    icon: const Icon(
                                      Icons.edit,
                                    ),
                                    label: const Text(
                                      "Modifier",
                                    ),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    label: const Text(
                                      "Supprimer",
                                      style: TextStyle(
                                        color: Colors.red,
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
              );

    if (!widget.showAppBar) return content;

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
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilAdminScreen(user: widget.user),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0, left: 5.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF00838F),
                child: Text(
                  widget.user.nom.trim().isNotEmpty
                      ? widget.user.nom.trim()[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}

