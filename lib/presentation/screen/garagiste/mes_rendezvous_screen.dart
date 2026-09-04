import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';

class MesRendezVousGaragisteScreen extends StatefulWidget {
final UserModel user;

const MesRendezVousGaragisteScreen({
super.key,
required this.user,
});

@override
State<MesRendezVousGaragisteScreen> createState() =>
_MesRendezVousGaragisteScreenState();
}

class _MesRendezVousGaragisteScreenState
extends State<MesRendezVousGaragisteScreen> {
bool _isLoading = true;

List<dynamic> _rendezVous = [];

String? _errorMessage;

@override
void initState() {
super.initState();
_chargerRendezVous();
}

// ============================================================
// CHARGER LES RDV CONFIRMÉS
// ============================================================

Future<void> _chargerRendezVous() async {
if (!mounted) return;

setState(() {
_isLoading = true;
_errorMessage = null;
});

try {
final token = await StorageService.getToken();

if (token == null || token.isEmpty) {
throw Exception(
"Session expirée. Veuillez vous reconnecter.",
);
}

// Le backend :
// - récupère uniquement les RDV du garagiste connecté
// - garde uniquement les RDV confirmer

final rdv =
await ApiService.getRendezVousGaragiste(token);

if (!mounted) return;

setState(() {
_rendezVous = rdv;
_isLoading = false;
});
} catch (e) {
debugPrint(
"Erreur chargement RDV garagiste : $e",
);

if (!mounted) return;

setState(() {
_errorMessage =
"Impossible de charger les rendez-vous.";
_isLoading = false;
});
}
}

// ============================================================
// FORMATER LA DATE
// ============================================================

String _formaterDate(dynamic date) {
if (date == null) {
return "Date inconnue";
}

try {
final dateTime =
DateTime.parse(date.toString());

return "${dateTime.day.toString().padLeft(2, '0')}/"
"${dateTime.month.toString().padLeft(2, '0')}/"
"${dateTime.year}";
} catch (_) {
return date.toString();
}
}

// ============================================================
// CARTE RENDEZ-VOUS
// ============================================================

Widget _buildRdvCard(dynamic rdv) {
  // ----------------------------------------------------------
  // Date et heure
  // ----------------------------------------------------------

  final date = _formaterDate(
    rdv["dateRdv"],
  );

  final heureDebut =
      rdv["heureDebut"]?.toString() ?? "--:--";

  final heureFin =
      rdv["heureFin"]?.toString() ?? "--:--";

  // ----------------------------------------------------------
  // Automobiliste
  // ----------------------------------------------------------

  final automobiliste =
      rdv["automobiliste"] is Map
          ? rdv["automobiliste"] as Map
          : {};

  final nomAutomobiliste =
      automobiliste["nom"]?.toString() ??
          "Automobiliste inconnu";

  // ----------------------------------------------------------
  // Véhicule
  // ----------------------------------------------------------

  final vehicule =
      rdv["vehicule"] is Map
          ? rdv["vehicule"] as Map
          : {};

  final marque =
      vehicule["marque"]?.toString() ?? "";

  final modele =
      vehicule["modele"]?.toString() ?? "";

  final categorie =
      vehicule["categorie"]?.toString() ?? "";

  return Card(
    elevation: 3,
    margin: const EdgeInsets.only(
      bottom: 16,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [

          // SECTION CLIENT + VEHICULE
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              const CircleAvatar(
                radius: 25,
                backgroundColor:
                Colors.orangeAccent,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [

                    Text(
                      nomAutomobiliste,
                      style:
                      const TextStyle(
                        fontSize: 18,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Marque + modèle
                    Text(
                      "$marque $modele",
                      style:
                      const TextStyle(
                        fontSize: 15,
                        fontWeight:
                        FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),

                    // Catégorie
                    if (categorie.isNotEmpty)
                      Text(
                        "Catégorie : $categorie",
                        style:
                        TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          const Divider(height: 30),

          // SECTION DATE ET HEURE (EN BAS)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    date,
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "$heureDebut - $heureFin",
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ============================================================
// MESSAGE ERREUR
// ============================================================

Widget _buildErrorWidget() {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [

const Icon(
Icons.error_outline,
size: 60,
color: Colors.red,
),

const SizedBox(height: 16),

Text(
_errorMessage!,
textAlign: TextAlign.center,
style:
const TextStyle(
fontSize: 16,
),
),

const SizedBox(height: 16),

ElevatedButton(
onPressed:
_chargerRendezVous,
child:
const Text("Réessayer"),
),
],
),
),
);
}

// ============================================================
// AUCUN RENDEZ-VOUS
// ============================================================

Widget _buildEmptyWidget() {
return Center(
child: Padding(
padding: const EdgeInsets.all(24),
child: Column(
mainAxisAlignment:
MainAxisAlignment.center,
children: [

Icon(
Icons.calendar_today_outlined,
size: 60,
color: Colors.grey[400],
),

const SizedBox(height: 16),

const Text(
"Aucun rendez-vous confirmé pour le moment.",
textAlign: TextAlign.center,
style: TextStyle(
fontSize: 16,
color: Colors.grey,
),
),
],
),
),
);
}

// ============================================================
// BUILD
// ============================================================

@override
Widget build(BuildContext context) {
return Scaffold(

appBar: AppBar(
title: const Text(
"Mes Rendez-vous",
),
elevation: 0,
),

body: _isLoading

? const Center(
child:
CircularProgressIndicator(),
)

    : _errorMessage != null

? _buildErrorWidget()

    : _rendezVous.isEmpty

? _buildEmptyWidget()

    : RefreshIndicator(
onRefresh:
_chargerRendezVous,
child:
ListView.builder(
padding:
const EdgeInsets.all(
16,
),
itemCount:
_rendezVous.length,
itemBuilder:
(context, index) {
return _buildRdvCard(
_rendezVous[index],
);
},
),
),
);
}
}
