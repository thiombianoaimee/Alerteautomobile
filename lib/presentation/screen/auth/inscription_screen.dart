import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
class InscriptionScreen extends StatefulWidget {
  const InscriptionScreen({super.key});

  @override
  State<InscriptionScreen> createState() => _InscriptionScreenState();
}
class _InscriptionScreenState extends State<InscriptionScreen> {

  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _telephoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();

  String _role = "automobiliste";
  bool _isLoading = false;

  @override
  void dispose() {
    _nomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  Future<void> _inscription() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Les mots de passe ne correspondent pas")),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {

      final response = await ApiService.register({
        "nom": _nomController.text.trim(),
        "telephone": _telephoneController.text.trim(),
        "email": _emailController.text.trim(),
        "motDePasse": _passwordController.text.trim(),
        "adresse": _adresseController.text.trim(),
        "role": _role,
      });

      debugPrint(response.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Inscription réussie"),
        ),
      );

    } catch (e) { debugPrint("Erreur inscription : $e"); if (!mounted) return; String message = e.toString(); if (message.startsWith("Exception: ")) { message = message.substring("Exception: ".length); } ScaffoldMessenger.of(context).showSnackBar( SnackBar( content: Text(message), ), ); } finally { if (mounted) { setState(() { _isLoading = false; }); } } }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un compte"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Icon(
                Icons.person_add,
                size: 80,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "Inscription",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              // Nom complet
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: "Nom complet",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Téléphone
              TextField(
                controller: _telephoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: "Téléphone",
                  prefixIcon: const Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Email
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  prefixIcon: const Icon(Icons.email),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Mot de passe
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Mot de passe",
                  prefixIcon: const Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Confirmation mot de passe
              TextField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirmer le mot de passe",
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // Adresse
              TextField(
                controller: _adresseController,
                decoration: InputDecoration(
                  labelText: "Adresse",
                  prefixIcon: const Icon(Icons.location_on),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Choix du rôle
              DropdownButtonFormField<String>(
                initialValue: _role,
                decoration: InputDecoration(
                  labelText: "Rôle",
                  prefixIcon: const Icon(Icons.badge),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "automobiliste",
                    child: Text("Automobiliste"),
                  ),
                  DropdownMenuItem(
                    value: "garagiste",
                    child: Text("Garagiste"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _role = value!;
                  });
                },
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _inscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700, // Bleu plus foncé pour le contraste
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                      : const Text(
                          "CRÉER MON COMPTE",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}