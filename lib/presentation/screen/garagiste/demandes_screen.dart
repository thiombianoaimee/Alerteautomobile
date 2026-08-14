import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import 'profil_garagiste_screen.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class DemandesScreen extends StatefulWidget {

  final UserModel user;

  const DemandesScreen({
    super.key,
    required this.user,
  });
  @override
  State<DemandesScreen> createState() => _DemandesScreenState();
}

class _DemandesScreenState extends State<DemandesScreen> {


  List<Map<String, dynamic>> demandes = [];
  bool chargement = true;

  @override
  void initState() {
    super.initState();
    chargerDemandes();
  }
  Future<void> chargerDemandes() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("Token introuvable");
      }

      final data = await ApiService.getDemandesGaragiste(token);

      setState(() {
        demandes = List<Map<String, dynamic>>.from(data);
        chargement = false;
      });

      debugPrint("Demandes récupérées : $demandes");

    } catch (e) {
      debugPrint("Erreur chargement demandes : $e");

      setState(() {
        chargement = false;
      });
    }
  }




  Color couleurStatut(String statut) {

    switch(statut) {

      case "Accepté":
        return Colors.green;

      case "Refusé":
        return Colors.red;

      default:
        return Colors.orange;

    }

  }




  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Gestion des demandes",
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
                  builder: (context) => ProfilGaragisteScreen(
                    user: widget.user,
                  ),
                ),
              );

            },
          ),

        ],

      ),


      body: demandes.isEmpty

          ? Center(

        child: Column(

          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [

            const Icon(

              Icons.event_note,

              size: 90,

              color: Colors.blue,

            ),


            const SizedBox(height:20),


            const Text(

              "Aucune demande de rendez-vous",

              style: TextStyle(

                fontSize:18,

                fontWeight: FontWeight.bold,

              ),

            ),



            const SizedBox(height:10),


            const Text(

              "Les nouvelles demandes des automobilistes apparaîtront ici.",

              textAlign: TextAlign.center,

              style: TextStyle(

                color: Colors.grey,

              ),

            ),

          ],

        ),

      )



          : ListView.builder(

        padding: const EdgeInsets.all(20),

        itemCount: demandes.length,


        itemBuilder: (context,index) {


          final demande = demandes[index];

          final date = DateTime.parse(demande["dateRdv"]);

          return Container(

            margin: const EdgeInsets.only(
              bottom:20,
            ),


            padding: const EdgeInsets.all(18),



            decoration: BoxDecoration(

              color: Colors.white,


              borderRadius:
              BorderRadius.circular(15),


              border: Border.all(

                color: Colors.blue.shade100,

              ),



              boxShadow: [

                BoxShadow(

                  color: Colors.grey.shade300,

                  blurRadius: 8,

                  offset:
                  const Offset(0,4),

                ),

              ],

            ),



            child: Column(


              crossAxisAlignment:
              CrossAxisAlignment.start,


              children: [



                Row(

                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(

                      backgroundColor:
                      Colors.blue,

                      child: Icon(

                        Icons.person,

                        color: Colors.white,

                      ),

                    ),


                    const SizedBox(width:15),

                    Expanded(
                      child: Text(
                        "Demande de ${demande["automobiliste"]?["nom"] ?? "Inconnu"}",
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                        softWrap: true,
                      ),
                    ),




                  ],

                ),

                const SizedBox(height: 8),

                Text(
                  "Téléphone : ${demande["automobiliste"]?["telephone"] ?? "Non renseigné"}",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Adresse : ${demande["automobiliste"]?["adresse"] ?? "Non renseignée"}",
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),


                const SizedBox(height:20),


                Text(
                  " Véhicule : "
                      "${demande["vehicule"]?["marque"] ?? ""} "
                      "${demande["vehicule"]?["modele"] ?? ""}",
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  "Immatriculation : "
                      "${demande["vehicule"]?["immatriculation"] ?? ""}",
                ),




                const SizedBox(height:8),




                Text(
                  " Date : "
                      "${date.day.toString().padLeft(2, '0')}/"
                      "${date.month.toString().padLeft(2, '0')}/"
                      "${date.year}",
                ),

                const SizedBox(height:8),
                Text(
                  " Heure : "
                      "${demande["heureDebut"] ?? ""} - "
                      "${demande["heureFin"] ?? ""}",
                ),





                const SizedBox(height:15),




                Container(

                  padding:
                  const EdgeInsets.symmetric(

                    horizontal:12,

                    vertical:6,

                  ),


                  decoration: BoxDecoration(

                    color: couleurStatut(
                      demande["statut"],
                    ).withValues(alpha: 0.15),

                    borderRadius:
                    BorderRadius.circular(20),

                  ),


                  child: Text(

                    demande["statut"],


                    style: TextStyle(

                      color:
                      couleurStatut(
                        demande["statut"],
                      ),

                      fontWeight:
                      FontWeight.bold,

                    ),

                  ),

                ),





                const SizedBox(height:20),




                Row(

                  children: [



                    Expanded(

                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final token = await StorageService.getToken();

                            if (token == null) {
                              throw Exception("Token introuvable");
                            }

                            final rendezVousId = demande["_id"];

                            await ApiService.acceptAppointment(
                              token,
                              rendezVousId,
                            );

                            if (!mounted) return;

                            setState(() {
                              demandes[index]["statut"] = "confirme";
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Rendez-vous accepté"),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erreur : $e"),
                              ),
                            );
                          }
                        },


                        icon: const Icon(
                          Icons.check,
                        ),


                        label: const Text(
                          "Accepter",
                        ),


                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.green,

                        ),

                      ),

                    ),




                    const SizedBox(width:10),





                    Expanded(

                      child: ElevatedButton.icon(

                        onPressed: () async {
                          try {
                            final token = await StorageService.getToken();

                            if (token == null) {
                              throw Exception("Token introuvable");
                            }

                            final rendezVousId = demande["_id"];

                            await ApiService.cancelAppointment(
                              token,
                              rendezVousId,
                            );

                            if (!mounted) return;

                            setState(() {
                              demandes[index]["statut"] = "annule";
                            });

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Rendez-vous refusé"),
                              ),
                            );
                          } catch (e) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Erreur : $e"),
                              ),
                            );
                          }
                        },


                        icon: const Icon(
                          Icons.close,
                        ),


                        label: const Text(
                          "Refuser",
                        ),


                        style:
                        ElevatedButton.styleFrom(

                          backgroundColor:
                          Colors.red,

                        ),

                      ),

                    ),



                  ],

                ),


              ],


            ),

          );


        },

      ),

    );

  }

}