import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_auto_screen.dart';
class RendezVousScreen extends StatefulWidget {

  final UserModel user;

  const RendezVousScreen({
    super.key,
    required this.user,
  });

  @override
  State<RendezVousScreen> createState() => _RendezVousScreenState();
}

class _RendezVousScreenState extends State<RendezVousScreen> {

  String? garagisteIdSelectionne;
  String? nomGaragisteSelectionne;

  DateTime? dateSelectionnee;
  String? creneauSelectionne;

  List<dynamic> garagistes = [];
  bool chargement = true;

  List<dynamic> creneaux = [];
  bool chargementCreneaux = false;

  List vehicules = [];
  bool chargementVehicules = true;

  String? vehiculeSelectionne;
  String? nomVehiculeSelectionne;

  @override
  void initState() {
    super.initState();
    chargerGaragistes();
    chargerVehicules();

  }


  Future<void> chargerGaragistes() async {

    try {

      final data = await ApiService.getGaragistes();

      setState(() {
        garagistes = data;
        chargement = false;
      });

    } catch(e) {

      debugPrint(e.toString());

      setState(() {
        chargement = false;
      });

    }

  }

  Future<void> chargerCreneaux() async {

    if (garagisteIdSelectionne == null ||
        dateSelectionnee == null) {
      return;
    }

    try {

      setState(() {
        chargementCreneaux = true;
      });


      String date =
          "${dateSelectionnee!.year}-"
          "${dateSelectionnee!.month.toString().padLeft(2,'0')}-"
          "${dateSelectionnee!.day.toString().padLeft(2,'0')}";

      debugPrint("Garagiste sélectionné : $garagisteIdSelectionne");
      debugPrint("Date sélectionnée : $date");

      final data = await ApiService.getCreneauxDisponibles(
        garagisteIdSelectionne!,
        date,
      );
      debugPrint("Créneaux reçus : $data");

      setState(() {

        creneaux = data;
        chargementCreneaux = false;

      });


    } catch(e) {

      debugPrint(e.toString());

      setState(() {
        chargementCreneaux = false;
      });

    }

  }
  Future<void> choisirDate() async {

    DateTime? date = await showDatePicker(

      context: context,

      initialDate: DateTime.now(),

      firstDate: DateTime.now(),

      lastDate: DateTime(2100),
      locale: const Locale('fr', 'FR'),
    );

    if (date != null) {

      setState(() {

        dateSelectionnee = date;

      });


      await chargerCreneaux();

    }


  }

  Future chargerVehicules() async {

    try {

      final savedToken = await StorageService.getToken();

      if(savedToken == null){

        setState(() {
          chargementVehicules = false;
        });

        return;
      }


      final liste = await ApiService.getMyVehicles(savedToken);


      setState(() {

        vehicules = liste;

        chargementVehicules = false;

      });


    } catch(e) {

      debugPrint("Erreur chargement véhicules : $e");


      setState(() {

        chargementVehicules = false;

      });

    }

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: const Text(
          "Planifier sa visite technique",
        ),

        centerTitle: true,

        actions: [

          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/notifications',
              );
            },
          ),


          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilAutoScreen(
                    user: widget.user,
                  ),
                ),
              );

            },
          ),

        ],

      ),



      body: SingleChildScrollView(

        padding: const EdgeInsets.all(20),


        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,


          children: [



            // =========================
            // ETAPE 1 : GARAGISTE
            // =========================


            const Text(

              "🔵 1. Choisir un garagiste",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

                color: Colors.blue,

              ),

            ),


            const SizedBox(height: 15),

            if (chargement)
              const Center(
                child: CircularProgressIndicator(),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: garagistes.length,
                itemBuilder: (context, index) {
                  final garagiste = garagistes[index];
                  final disponibilites = garagiste["disponibilites"] as List;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 15),
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Text(
                            garagiste["nom"],
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "Téléphone : ${garagiste["telephone"] ?? "Non renseigné"}",
                          ),

                          const SizedBox(height: 5),

                          Text(
                            "Adresse : ${garagiste["adresse"] ?? "Non renseignée"}",
                          ),

                          const SizedBox(height: 10),

                          if (disponibilites.isEmpty)

                            const Text(
                              "Aucune disponibilité",
                              style: TextStyle(color: Colors.red),
                            )

                          else

                            ...disponibilites.map((d) => ListTile(
                              title: Text(
                                "${d["jourDebut"]} - ${d["jourFin"]}",
                              ),
                              subtitle: Text(
                                "${d["heureDebut"]} à ${d["heureFin"]}",
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    garagisteIdSelectionne = garagiste["_id"];
                                    nomGaragisteSelectionne = garagiste["nom"];
                                  });
                                  debugPrint("Garagiste choisi : ${garagiste["_id"]}");
                                },
                                child: const Text("Choisir"),
                              ),
                            )),
                        ],
                      ),
                    ),
                  );
                },
              ),



            const Divider(height: 40),




            // =========================
            // ETAPE 2 : DATE
            // =========================


            const Text(

              "🟢 2. Choisir une date",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

                color: Colors.green,

              ),

            ),



            const SizedBox(height: 15),



            ElevatedButton.icon(

              onPressed: choisirDate,


              icon: const Icon(
                Icons.calendar_month,
              ),


              label: Text(

                dateSelectionnee == null

                    ? "Choisir une date"

                    :

                "${dateSelectionnee!.day}/"
                    "${dateSelectionnee!.month}/"
                    "${dateSelectionnee!.year}",

              ),

            ),



            const Divider(height: 40),




            // =========================
            // ETAPE 3 : CRENEAU
            // =========================


            const Text(

              "🔵 3. Choisir un créneau",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

                color: Colors.blue,

              ),

            ),



            const SizedBox(height: 15),

            if (chargementCreneaux)

              const Center(
                child: CircularProgressIndicator(),
              )


            else if (creneaux.isEmpty)

              const Text(
                "Aucun créneau disponible",
                style: TextStyle(
                  color: Colors.red,
                ),
              )


            else

              Column(

                children: creneaux.map((creneau) {

                  final heure =
                      "${creneau["heureDebut"]} - ${creneau["heureFin"]}";


                  return Card(

                    child: ListTile(

                      title: Text(
                        heure,
                      ),

                      trailing: ElevatedButton(

                        onPressed: () {

                          setState(() {

                            creneauSelectionne = heure;

                          });

                        },

                        child: const Text(
                          "Choisir",
                        ),

                      ),

                    ),

                  );

                }).toList(),

              ),


            const Divider(height: 40),

// =========================
// ETAPE 4 : VEHICULE
// =========================

            const Text(

              "🟣 4. Choisir un véhicule",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

                color: Colors.purple,

              ),

            ),


            const SizedBox(height: 15),


            if (chargementVehicules)

              const Center(

                child: CircularProgressIndicator(),

              )


            else if (vehicules.isEmpty)

              const Text(

                "Aucun véhicule enregistré",

                style: TextStyle(

                  color: Colors.red,

                ),

              )


            else

              Column(

                children: vehicules.map((vehicule) {


                  return Card(

                    margin: const EdgeInsets.only(bottom: 15),


                    child: Padding(

                      padding: const EdgeInsets.all(15),


                      child: Column(

                        crossAxisAlignment: CrossAxisAlignment.start,


                        children: [


                          Text(

                            "${vehicule["marque"]} ${vehicule["modele"]}",

                            style: const TextStyle(

                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                            ),

                          ),



                          const SizedBox(height: 8),



                          ElevatedButton(

                            onPressed: () {


                              setState(() {


                                vehiculeSelectionne =
                                vehicule["_id"];


                                nomVehiculeSelectionne =
                                "${vehicule["marque"]} ${vehicule["modele"]}";


                              });


                            },


                            child: const Text(

                              "Choisir",

                            ),

                          ),


                        ],

                      ),

                    ),

                  );


                }).toList(),

              ),


            const Divider(height: 40),


            // =========================
            // ETAPE 5 : CONFIRMATION
            // =========================


            const Text(

              "🟢 4. Confirmation du rendez-vous",

              style: TextStyle(

                fontSize: 22,

                fontWeight: FontWeight.bold,

                color: Colors.green,

              ),

            ),



            const SizedBox(height: 15),


            Text(
              "Garagiste : ${nomGaragisteSelectionne ?? "Non sélectionné"}",
            ),

            Text(
              "Véhicule : ${nomVehiculeSelectionne ?? "Non sélectionné"}",
            ),

            Text(

              "Date : ${
                  dateSelectionnee == null
                      ? "Non sélectionnée"
                      : "${dateSelectionnee!.day}/${dateSelectionnee!.month}/${dateSelectionnee!.year}"
              }",

            ),



            Text(
              "Créneau : ${creneauSelectionne ?? "Non sélectionné"}",
            ),



            const SizedBox(height: 25),



            SizedBox(

              width: double.infinity,


              child: ElevatedButton.icon(

                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  if (garagisteIdSelectionne == null ||
                      dateSelectionnee == null ||
                      creneauSelectionne == null ||
                      vehiculeSelectionne == null) {

                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Veuillez choisir le garagiste, la date et le créneau",
                        ),
                      ),
                    );

                    return;
                  }


                  final automobilisteId =
                  await StorageService.getUserId();

                  if (!mounted) return;
                  if (automobilisteId == null) {
                    messenger.showSnackBar(

                      const SnackBar(
                        content: Text(
                          "Utilisateur non connecté",
                        ),
                      ),
                    );

                    return;
                  }


                  // Séparer "08:00 - 09:00"
                  final heures = creneauSelectionne!.split(" - ");


                  final rdvData = {

                    "automobiliste": automobilisteId,

                    "garagiste": garagisteIdSelectionne,

                    "vehicule": vehiculeSelectionne,

                    "dateRdv":
                    "${dateSelectionnee!.year}-"
                        "${dateSelectionnee!.month.toString().padLeft(2,'0')}-"
                        "${dateSelectionnee!.day.toString().padLeft(2,'0')}",

                    "heureDebut": heures[0],

                    "heureFin": heures[1],

                  };


                  try {

                    final resultat = await ApiService.creerRdv(
                      rdvData,
                    );

                    if (!mounted) return;

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          resultat["message"] ?? "Rendez-vous créé",
                        ),
                      ),
                    );


                  } catch(e) {

                    debugPrint(e.toString());

                    if (!mounted) return;
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Erreur lors de la création du rendez-vous",
                        ),
                      ),
                    );

                  }



                },


                icon: const Icon(
                  Icons.check_circle,
                ),


                label: const Text(
                  "Confirmer le rendez-vous",
                ),

              ),

            ),


          ],

        ),

      ),

    );

  }

}