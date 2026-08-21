import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_admin_screen.dart';
import 'creneau_admin_screen.dart';
import 'rdv_garagiste_admin_screen.dart';

class GaragistesAdminScreen extends StatefulWidget {
final UserModel user;

const GaragistesAdminScreen({
super.key,
required this.user,
});

@override
State<GaragistesAdminScreen> createState() =>
_GaragistesAdminScreenState();
}

class _GaragistesAdminScreenState
extends State<GaragistesAdminScreen> {

List<dynamic> garagistes = [];

bool isLoading = true;

// Compteur des disponibilités
Map<String, int> nombreDisponibilites = {};

// Compteur des rendez-vous
Map<String, int> nombreRdv = {};

@override
void initState() {
super.initState();
chargerGaragistes();
}

// ============================================================
// CHARGER LES GARAGISTES + COMPTEURS
// ============================================================

Future<void> chargerGaragistes() async {
try {
final data = await ApiService.getGaragistes();

final token = await StorageService.getToken();

if (token == null) {
throw Exception("Token introuvable");
}

// ========================================================
// COMPTEUR DES DISPONIBILITES
// ========================================================

Map<String, int> compteursDisponibilites = {};

for (final garagiste in data) {

final id = garagiste["_id"]?.toString();

if (id != null) {

/*
           * On récupère les créneaux du garagiste.
           *
           * Cette méthode existe déjà dans ton ApiService.
           */
  final creneaux =
  await ApiService.getCreneauxByGaragiste(id);

compteursDisponibilites[id] =
creneaux.length;
}
}

// ========================================================
// COMPTEUR DES RENDEZ-VOUS
// ========================================================

final rdvs =
await ApiService.getAllAppointments(token);

Map<String, int> compteursRdv = {};

for (final rdv in rdvs) {

final garagiste =
rdv["garagiste"];

if (garagiste != null && garagiste is Map) {

final id =
garagiste["_id"]?.toString();

if (id != null) {

compteursRdv[id] =
(compteursRdv[id] ?? 0) + 1;
}
}
}

if (!mounted) return;

setState(() {

garagistes = data;

nombreDisponibilites =
compteursDisponibilites;

nombreRdv =
compteursRdv;

isLoading = false;
});

} catch (e) {

if (!mounted) return;

setState(() {
isLoading = false;
});

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Erreur lors du chargement : $e",
),
),
);
}
}

// ============================================================
// ACTIVER / DESACTIVER
// ============================================================

Future<void> changerStatut(
Map<String, dynamic> garagiste,
) async {

try {

final token =
await StorageService.getToken();

if (token == null) {
throw Exception(
"Token introuvable",
);
}

final id =
garagiste["_id"]?.toString();

if (id == null) {
throw Exception(
"ID du garagiste introuvable",
);
}

await ApiService.toggleUserStatus(
id,
token,
);

// Recharger les données
await chargerGaragistes();

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(
content: Text(
"Statut du compte modifié avec succès",
),
),
);

} catch (e) {

if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
SnackBar(
content: Text(
"Erreur : $e",
),
),
);
}
}

// ============================================================
// CLIQUER SUR DISPONIBILITES
// ============================================================
  void ouvrirDisponibilites(
      String garagisteId,
      String nomGaragiste,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreneauAdminScreen(
          garagisteId: garagisteId,
          nomGaragiste: nomGaragiste,
        ),
      ),
    );
  }

// ============================================================
// CLIQUER SUR RENDEZ-VOUS
// ============================================================
  void ouvrirRendezVous(
      String garagisteId,
      String nomGaragiste,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RdvGaragisteAdminScreen(
          garagisteId: garagisteId,
          nomGaragiste: nomGaragiste,
        ),
      ),
    );
  }

// ============================================================
// INTERFACE
// ============================================================

@override
Widget build(BuildContext context) {

return Scaffold(

appBar: AppBar(

title: const Text(
"Garagistes",
),

actions: [

// Actualiser
IconButton(
onPressed:
chargerGaragistes,

icon: const Icon(
Icons.refresh,
),
),

// Profil administrateur
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
builder: (context) =>
ProfilAdminScreen(
user: widget.user,
),
),
);
},
),
],
),

// ========================================================
// BODY
// ========================================================

body: isLoading

? const Center(
child:
CircularProgressIndicator(),
)

    : garagistes.isEmpty

? const Center(
child: Text(
"Aucun garagiste trouvé",
style: TextStyle(
fontSize: 16,
),
),
)

    : ListView.builder(

padding:
const EdgeInsets.all(10),

itemCount:
garagistes.length,

itemBuilder:
(context, index) {

final garagiste =
garagistes[index];

// =================================================
// INFORMATIONS
// =================================================

final nom =
garagiste["nom"]
    ?.toString() ??
"Inconnu";

final email =
garagiste["email"]
    ?.toString() ??
"Non renseigné";

final telephone =
garagiste["telephone"]
    ?.toString() ??
"Non renseigné";

final adresse =
garagiste["adresse"]
    ?.toString() ??
"Non renseignée";

final id =
garagiste["_id"]
    ?.toString();

// =================================================
// STATUT
// =================================================

final actif =
garagiste["actif"] != false;

// =================================================
// COMPTEURS
// =================================================

final nombreCreneaux =
nombreDisponibilites[
id ?? ""
] ??
0;

final nombreRendezVous =
nombreRdv[
id ?? ""
] ??
0;

// =================================================
// CARD
// =================================================

return Card(

margin:
const EdgeInsets.only(
bottom: 10,
),

child: Padding(

padding:
const EdgeInsets.all(12),

child: Column(

crossAxisAlignment:
CrossAxisAlignment.start,

children: [

// ==========================================
// NOM + STATUT
// ==========================================

Row(

children: [

const CircleAvatar(
child: Icon(
Icons.build,
),
),

const SizedBox(
width: 10,
),

Expanded(

child: Text(

nom,

style:
const TextStyle(
fontWeight:
FontWeight.bold,
fontSize: 16,
),
),
),

// Badge statut
Container(

padding:
const EdgeInsets
    .symmetric(
horizontal: 8,
vertical: 4,
),

decoration:
BoxDecoration(

color: actif
? Colors.green
    .withValues(
alpha: 0.1,
)
    : Colors.red
    .withValues(
alpha: 0.1,
),

borderRadius:
BorderRadius
    .circular(
8,
),
),

child: Text(

actif
? "Actif"
    : "Désactivé",

style: TextStyle(

color: actif
? Colors.green
    : Colors.red,

fontWeight:
FontWeight.bold,
),
),
),
],
),

const SizedBox(
height: 10,
),

// ==========================================
// INFORMATIONS
// ==========================================

Text(
"Email : $email",
),

Text(
"Téléphone : $telephone",
),

Text(
"Adresse : $adresse",
),

const SizedBox(
height: 10,
),

// ==========================================
// DISPONIBILITES + RDV
// ==========================================

Row(

children: [

// DISPONIBILITES
const Icon(
Icons.access_time,
size: 20,
),

const SizedBox(
width: 5,
),

InkWell(

onTap: id == null
? null
    : () {

ouvrirDisponibilites(
id,
nom,
);
},

child: Text(

"Disponibilités : "
"$nombreCreneaux",

style:
const TextStyle(
color:
Colors.blue,
fontWeight:
FontWeight.bold,
),
),
),

const SizedBox(
width: 25,
),

// RENDEZ-VOUS
const Icon(
Icons.calendar_month,
size: 20,
),

const SizedBox(
width: 5,
),

InkWell(

onTap: id == null
? null
    : () {

ouvrirRendezVous(
id,
nom,
);
},

child: Text(

"RDV : "
"$nombreRendezVous",

style:
const TextStyle(
color:
Colors.blue,
fontWeight:
FontWeight.bold,
),
),
),
],
),

const SizedBox(
height: 10,
),

// ==========================================
// STATUT + BOUTON
// ==========================================

Row(

mainAxisAlignment:
MainAxisAlignment
    .spaceBetween,

children: [

Text(

actif
? "Statut : 🟢 Actif"
    : "Statut : 🔴 Désactivé",

style:
const TextStyle(
fontWeight:
FontWeight.bold,
),
),

ElevatedButton(

onPressed: () {

changerStatut(
garagiste,
);
},

child: Text(

actif
? "Désactiver"
    : "Activer",
),
),
],
),
],
),
),
);
},
),
);
}
}

