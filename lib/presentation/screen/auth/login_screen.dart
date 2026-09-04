import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
import '../automobiliste/dashboard_auto_screen.dart';
import '../garagiste/dashboard_garagiste_screen.dart';
import '../administrateur/dashboard_admini.dart';
import 'inscription_screen.dart';
import 'mot_de_passe_oublie_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;
  void _login() async {
    // Fermer le clavier pour éviter les bugs de transition sur l'émulateur
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Veuillez remplir tous les champs";
      });
      return;
    }
    try {

      final response = await ApiService.login(email, password);


      // Sauvegarde du token JWT
      await StorageService.saveToken(
        response['token'],
      );

      await StorageService.saveUserId(
        response['utilisateur']['_id'],
      );

      setState(() {
        _isLoading = false;
      });

      final utilisateur = response['utilisateur'];

      final user = UserModel(
        id: utilisateur['_id'],
        email: utilisateur['email'],
        role: utilisateur['role'],
        nom: utilisateur['nom'],
        adresse: utilisateur['adresse'] ?? '',
        telephone: utilisateur['telephone'] ?? '',
      );

      if (!mounted) return;

      if (user.role == 'automobiliste') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardAutoScreen(user: user),
          ),
        );
      } else if (user.role == 'garagiste') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardGaragisteScreen(user: user),
          ),
        );
      } else if (user.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardAdminScreen(user: user),
          ),
        );
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur de connexion";
      });
    }
  }



  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Connexion"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: const Icon(
                Icons.directions_car_filled,
                size: 80,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Heureux de vous revoir !",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Connectez-vous pour accéder à votre espace.",
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 40),
                  if (_errorMessage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Champ email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: "Votre email",
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Champ mot de passe
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: "Votre mot de passe",
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MotDePasseOublieScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        "Mot de passe oublié ?",
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Bouton connexion
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "SE CONNECTER",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const InscriptionScreen(),
                          ),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Pas encore de compte ? ",
                          style: TextStyle(color: Colors.grey[600]),
                          children: [
                            TextSpan(
                              text: "S'inscrire",
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}