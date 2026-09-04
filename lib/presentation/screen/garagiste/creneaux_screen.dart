import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
import 'profil_garagiste_screen.dart';

class CreneauxScreen extends StatefulWidget {

  final UserModel user;

  const CreneauxScreen({
    super.key,
    required this.user,
  });

  @override
  State<CreneauxScreen> createState() => _CreneauxScreenState();
}

class _CreneauxScreenState extends State<CreneauxScreen> {

  final List<String> jours = [
    "Lundi",
    "Mardi",
    "Mercredi",
    "Jeudi",
    "Vendredi",
    "Samedi",
    "Dimanche",
  ];


  String? jourDebut;
  String? jourFin;
  bool disponibiliteExiste = false;
  bool chargement = true;
  String? creneauId;
  bool modeModification = false;


  TimeOfDay heureDebut = const TimeOfDay(
    hour: 8,
    minute: 0,
  );


  TimeOfDay heureFin = const TimeOfDay(
    hour: 16,
    minute: 0,
  );

  @override
  void initState() {
    super.initState();
    chargerDisponibilite();
  }

  Future<void> choisirHeure(bool debut) async {
    TimeOfDay initial = debut ? heureDebut : heureFin;

    TimeOfDay? heure = await showTimePicker(
      context: context,
      initialEntryMode: TimePickerEntryMode.dial, // Mode horloge (plus stable et joli)
      helpText: debut ? "CHOISIR HEURE DE DÉBUT" : "CHOISIR HEURE DE FIN",
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
      initialTime: initial,
    );

    if (heure != null) {
      setState(() {
        if (debut) {
          heureDebut = heure;
        } else {
          heureFin = heure;
        }
      });
    }
  }

  void activerModification() {
    if (creneauId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Aucune disponibilité à modifier."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      modeModification = true;
    });
  }

  Future<void> enregistrerDisponibilite() async {
    if (jourDebut == null || jourFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Veuillez définir vos jours de disponibilité.",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final disponibilite = {
      "jourDebut": jourDebut,
      "jourFin": jourFin,
      "heureDebut":
      "${heureDebut.hour.toString().padLeft(2, '0')}:${heureDebut.minute.toString().padLeft(2, '0')}",
      "heureFin":
      "${heureFin.hour.toString().padLeft(2, '0')}:${heureFin.minute.toString().padLeft(2, '0')}",
    };

    try {
      final token = await StorageService.getToken();

      if (!mounted) return;

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Utilisateur non connecté"),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // ============================
      // MODIFICATION
      // ============================
      if (modeModification) {
        if (creneauId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Identifiant de disponibilité introuvable."),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        final response = await ApiService.updateCreneau(
          creneauId!,
          disponibilite,
          token,
        );

        debugPrint(response.toString());

        if (!mounted) return;

        setState(() {
          modeModification = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Disponibilité modifiée avec succès.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        await chargerDisponibilite();
      }

      // ============================
      // AJOUT
      // ============================
      else {
        final response = await ApiService.addCreneau(
          disponibilite,
          token,
        );

        debugPrint(response.toString());

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Disponibilité enregistrée avec succès.",
            ),
            backgroundColor: Colors.green,
          ),
        );

        await chargerDisponibilite();
      }
    } catch (e) {
      debugPrint("Erreur disponibilité : $e");

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur : $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> chargerDisponibilite() async {
    try {
      final creneaux = await ApiService.getCreneauxByGaragiste(
        widget.user.id,
      );

      if (!mounted) return;

      if (creneaux.isNotEmpty) {
        final creneau = creneaux.first;

        setState(() {
          disponibiliteExiste = true;
          modeModification = false;

          creneauId = creneau["_id"]?.toString();

          jourDebut = creneau["jourDebut"]?.toString();
          jourFin = creneau["jourFin"]?.toString();

          final heureDebutString =
              creneau["heureDebut"]?.toString() ?? "08:00";

          final heureFinString =
              creneau["heureFin"]?.toString() ?? "16:00";

          final debutParts = heureDebutString
              .trim()
              .split(":");

          final finParts = heureFinString
              .trim()
              .split(":");

          heureDebut = TimeOfDay(
            hour: int.parse(debutParts[0]),
            minute: int.parse(debutParts[1]),
          );

          heureFin = TimeOfDay(
            hour: int.parse(finParts[0]),
            minute: int.parse(finParts[1]),
          );

          chargement = false;
        });
      } else {
        setState(() {
          disponibiliteExiste = false;
          chargement = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement disponibilité : $e");

      if (!mounted) return;

      setState(() {
        chargement = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {


    return Scaffold(

      appBar: AppBar(

        title: const Text(
          "Mes disponibilités",
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



      body: SingleChildScrollView(


        padding: const EdgeInsets.all(20),



        child: Column(


          crossAxisAlignment:
          CrossAxisAlignment.start,



          children: [



            const Center(

              child: Icon(

                Icons.event_available,

                size: 80,

                color: Colors.green,

              ),

            ),



            const SizedBox(height: 15),



            const Center(

              child: Text(

                "Configurez vos horaires de travail",

                style: TextStyle(

                  fontSize: 23,

                  fontWeight: FontWeight.bold,

                ),

              ),

            ),



            const SizedBox(height: 10),



            const Center(

              child: Text(

                "Les automobilistes pourront réserver uniquement pendant vos périodes disponibles.",

                textAlign: TextAlign.center,

                style: TextStyle(

                  color: Colors.grey,

                  fontSize: 15,

                ),

              ),

            ),



            const SizedBox(height: 35),




            const Text(

              "📅 Période de disponibilité",

              style: TextStyle(

                fontSize: 21,

                fontWeight: FontWeight.bold,

                color: Colors.blue,

              ),

            ),



            const SizedBox(height: 20),




            DropdownButtonFormField<String>(

              initialValue: jourDebut,


              decoration: InputDecoration(

                labelText: "Disponible à partir de",

                prefixIcon: const Icon(
                  Icons.calendar_today,
                ),

                border: OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(12),

                ),

              ),



              items: jours.map((jour) {


                return DropdownMenuItem(

                  value: jour,

                  child: Text(jour),

                );


              }).toList(),



              onChanged: (value) {


                setState(() {

                  jourDebut = value;

                });


              },


            ),



            const SizedBox(height: 20),




            DropdownButtonFormField<String>(


              initialValue: jourFin,


              decoration: InputDecoration(

                labelText: "Disponible jusqu'à",

                prefixIcon: const Icon(
                  Icons.calendar_today,
                ),

                border: OutlineInputBorder(

                  borderRadius:
                  BorderRadius.circular(12),

                ),

              ),



              items: jours.map((jour) {


                return DropdownMenuItem(

                  value: jour,

                  child: Text(jour),

                );


              }).toList(),



              onChanged: (value) {


                setState(() {

                  jourFin = value;

                });


              },


            ),




            const SizedBox(height: 35),





            const Text(

              "🕒 Horaires de travail",

              style: TextStyle(

                fontSize: 21,

                fontWeight: FontWeight.bold,

                color: Colors.green,

              ),

            ),




            const SizedBox(height: 15),




            ListTile(

              leading: const Icon(

                Icons.access_time,

                color: Colors.green,

              ),


              title: const Text(
                "Heure de début",
              ),

              subtitle: Text(
                "${heureDebut.hour.toString().padLeft(2, '0')}:${heureDebut.minute.toString().padLeft(2, '0')}",
              ),



              trailing: ElevatedButton(

                onPressed: () {

                  choisirHeure(true);

                },


                child: const Text(
                  "Modifier",
                ),

              ),

            ),





            const Divider(),




            ListTile(

              leading: const Icon(

                Icons.access_time_filled,

                color: Colors.green,

              ),


              title: const Text(
                "Heure de fin",
              ),

              subtitle: Text(
                "${heureFin.hour.toString().padLeft(2, '0')}:${heureFin.minute.toString().padLeft(2, '0')}",
              ),


              trailing: ElevatedButton(

                onPressed: () {

                  choisirHeure(false);

                },


                child: const Text(
                  "Modifier",
                ),

              ),

            ),




            const SizedBox(height: 40),





            SizedBox(

              width: double.infinity,

              height: 50,


              child: ElevatedButton.icon(

                onPressed: disponibiliteExiste && !modeModification
                    ? activerModification
                    : enregistrerDisponibilite,

                icon: Icon(
                  disponibiliteExiste && !modeModification
                      ? Icons.edit
                      : Icons.save,
                ),

                label: Text(
                  disponibiliteExiste && !modeModification
                      ? "Modifier ma disponibilité"
                      : "Enregistrer les modifications",

                  style: const TextStyle(
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