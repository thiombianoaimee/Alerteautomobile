import 'package:flutter/material.dart';

import '../auth/login_screen.dart';
import '../auth/inscription_screen.dart';

class AccueilScreen extends StatelessWidget {
  const AccueilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Logo de l'application
              const Icon(
                Icons.directions_car,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(height: 20),

              const Text(
                "AutoAlert Burkina Faso",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                "Gérez vos véhicules et recevez des alertes "
                    "avant l'expiration de votre visite technique.",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Bouton connexion
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text("Se connecter"),
                ),
              ),

              const SizedBox(height: 15),

              // Bouton inscription
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const InscriptionScreen(),
                      ),
                    );
                  },
                  child: const Text("Créer un compte"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}