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
  String? categorie;

  Future<void> chargerToken() async {

    final savedToken = await StorageService.getToken();

    setState(() {
      token = savedToken ?? "";
    });

    debugPrint("Token véhicule : $token");
  }

  Future<void> choisirDate() async {
    DateTime aujourdHui = DateTime.now();

    DateTime? date = await showDatePicker(
      context: context,
      initialDate: aujourdHui,
      firstDate: DateTime(2000),
      lastDate: aujourdHui,
      locale: const Locale('fr', 'FR'),
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
      categorie = null;
      vehiculeEnregistre = false;
    });
  }

  Future<void> enregistrerVehicule() async {

    if (immatriculationController.text.isEmpty ||
        marqueController.text.isEmpty ||
        modeleController.text.isEmpty ||
        categorie == null ||
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
        "categorie": categorie,
        "dateDerniereVisiteTechnique": dateVisiteTechnique!.toIso8601String(),

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
        title: const Text("Enregistrer son véhicule"),
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


      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.02),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_rounded,
                    size: 60,
                    color: Color(0xFF009688),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Enregistrer un véhicule",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF009688),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Remplissez les informations ci-dessous",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 32),
                _buildModernField(
                  controller: immatriculationController,
                  label: "IMMATRICULATION",
                  icon: Icons.confirmation_number_outlined,
                ),
                const SizedBox(height: 16),
                _buildModernField(
                  controller: marqueController,
                  label: "MARQUE",
                  icon: Icons.car_repair_outlined,
                ),
                const SizedBox(height: 16),
                _buildModernField(
                  controller: modeleController,
                  label: "MODÈLE",
                  icon: Icons.directions_car_outlined,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: categorie,
                  decoration: _inputDecoration(
                    "CATÉGORIE DU VÉHICULE",
                    Icons.category_outlined,
                  ),
                  items: const [
                    DropdownMenuItem(value: "particulier", child: Text("Particulier")),
                    DropdownMenuItem(value: "utilitaire", child: Text("Utilitaire")),
                    DropdownMenuItem(value: "transport_personnes", child: Text("Transport de personnes")),
                    DropdownMenuItem(value: "taxi", child: Text("Taxi")),
                    DropdownMenuItem(value: "auto_ecole", child: Text("Auto-école")),
                    DropdownMenuItem(value: "tricycle", child: Text("Tricycle")),
                  ],
                  onChanged: (value) => setState(() => categorie = value),
                ),
                const SizedBox(height: 8),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "DATE DE LA DERNIÈRE VISITE TECHNIQUE",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: choisirDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF009688).withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: const Color(0xFF009688), width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, color: Color(0xFF009688)),
                        const SizedBox(width: 12),
                        Text(
                          dateVisiteTechnique == null
                              ? "Cliquer pour sélectionner une date"
                              : "${dateVisiteTechnique!.day.toString().padLeft(2, '0')}/${dateVisiteTechnique!.month.toString().padLeft(2, '0')}/${dateVisiteTechnique!.year}",
                          style: TextStyle(
                            fontSize: 16,
                            color: dateVisiteTechnique == null ? Colors.grey : Colors.black,
                            fontWeight: dateVisiteTechnique == null ? FontWeight.normal : FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                if (!vehiculeEnregistre)
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: enregistrerVehicule,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF009688),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                        shadowColor: const Color(0xFF009688).withValues(alpha: 0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "VALIDER L'ENREGISTREMENT",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (vehiculeEnregistre) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: viderFormulaire,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 6,
                        shadowColor: Colors.orange.withValues(alpha: 0.4),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_rounded, size: 28),
                          SizedBox(width: 12),
                          Text(
                            "AJOUTER UN AUTRE VÉHICULE",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: _inputDecoration(label, icon),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w800),
      prefixIcon: Icon(icon, color: const Color(0xFF009688)),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: const Color(0xFF009688).withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF009688), width: 2.5),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
      ),
    );
  }
}
