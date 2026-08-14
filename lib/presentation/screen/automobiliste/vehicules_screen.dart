import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
class VehiculesScreen extends StatefulWidget {

  final UserModel user;

  const VehiculesScreen({
    super.key,
    required this.user,
  });

  @override
  State<VehiculesScreen> createState() => _VehiculesScreenState();
}

class _VehiculesScreenState extends State<VehiculesScreen> {
  String token = "";
  bool vehiculeEnregistre = false;

  final TextEditingController immatriculationController =
  TextEditingController();

  final TextEditingController marqueController =
  TextEditingController();

  final TextEditingController modeleController =
  TextEditingController();

  DateTime? dateVisiteTechnique;
  Future<void> chargerToken() async {

    final savedToken = await StorageService.getToken();

    setState(() {
      token = savedToken ?? "";
    });

    debugPrint("Token véhicule : $token");
  }

  Future<void> choisirDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        dateVisiteTechnique = date;
      });
    }
  }


  void viderFormulaire() {
    immatriculationController.clear();
    marqueController.clear();
    modeleController.clear();

    setState(() {
      dateVisiteTechnique = null;
    });
  }

  Future<void> enregistrerVehicule() async {

    if (immatriculationController.text.isEmpty ||
        marqueController.text.isEmpty ||
        modeleController.text.isEmpty ||
        dateVisiteTechnique == null) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez remplir tous les champs."),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }


   final resultat= await ApiService.addVehicle(
      {
        "marque": marqueController.text,
        "modele": modeleController.text,
        "immatriculation": immatriculationController.text,
        "dateVisiteTechnique": dateVisiteTechnique!.toIso8601String(),
      },
      token,

    );
    debugPrint(resultat.toString());

    if (!mounted) return;
    setState(() {
      vehiculeEnregistre = true;
    });


    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Véhicule enregistré avec succès."),
        backgroundColor: Colors.green,
      ),
    );
  }
  @override
  void initState() {
    super.initState();
    chargerToken();
  }

  @override
  void dispose() {

    immatriculationController.dispose();
    marqueController.dispose();
    modeleController.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Enregister son véhucule"),
        centerTitle: true,
          actions: [

      IconButton(
      icon: const Icon(Icons.notifications),
      onPressed: () {
        Navigator.pushNamed(context, '/notifications');
      },
    ),

    IconButton(
    icon: const Icon(Icons.person),
    onPressed: () {
      Navigator.pushNamed(
        context,
        '/profil',
        arguments: widget.user,
      );
    },
    ),

    ],
      ),


      body: Padding(

        padding: const EdgeInsets.all(20),

        child: SingleChildScrollView(

          child: Column(

            children: [


              const Icon(
                Icons.directions_car,
                size: 80,
                color: Colors.blue,
              ),


              const SizedBox(height: 20),



              const Text(
                "Enregistrer un véhicule",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),



              const SizedBox(height: 30),



              TextField(

                controller: immatriculationController,

                decoration: InputDecoration(

                  labelText: "Immatriculation",

                  prefixIcon:
                  const Icon(Icons.confirmation_number),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                ),

              ),



              const SizedBox(height: 15),



              TextField(

                controller: marqueController,

                decoration: InputDecoration(

                  labelText: "Marque",

                  prefixIcon:
                  const Icon(Icons.car_repair),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                ),

              ),



              const SizedBox(height: 15),



              TextField(

                controller: modeleController,

                decoration: InputDecoration(

                  labelText: "Modèle",

                  prefixIcon:
                  const Icon(Icons.directions_car),

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),

                ),

              ),



              const SizedBox(height: 15),




              InkWell(

                onTap: choisirDate,

                child: InputDecorator(

                  decoration: InputDecoration(

                    labelText:
                    "Date de la dernière visite technique",

                    prefixIcon:
                    const Icon(Icons.calendar_month),

                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),

                  ),


                  child: Text(

                    dateVisiteTechnique == null

                        ? "Sélectionner une date"

                        : "${dateVisiteTechnique!.day}/"
                        "${dateVisiteTechnique!.month}/"
                        "${dateVisiteTechnique!.year}",

                  ),

                ),

              ),



              const SizedBox(height: 30),




              SizedBox(

                width: double.infinity,

                child: ElevatedButton.icon(

                  onPressed: enregistrerVehicule,

                  icon: const Icon(Icons.save),

                  label: const Text("Enregistrer"),

                ),

              ),




              const SizedBox(height: 15),




              // Le bouton apparaît seulement après l'enregistrement

              if (vehiculeEnregistre)

                SizedBox(

                  width: double.infinity,

                  child: OutlinedButton.icon(

                    onPressed: viderFormulaire,

                    icon: const Icon(Icons.add),

                    label:
                    const Text("Ajouter un autre véhicule"),

                  ),

                ),


            ],

          ),

        ),

      ),

    );

  }

}