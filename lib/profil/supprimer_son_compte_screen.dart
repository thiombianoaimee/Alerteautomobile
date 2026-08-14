import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class SupprimerCompteScreen extends StatefulWidget {
  final UserModel user;

  const SupprimerCompteScreen({
    super.key,
    required this.user,
  });

  @override
  State<SupprimerCompteScreen> createState() =>
      _SupprimerCompteScreenState();
}

class _SupprimerCompteScreenState
    extends State<SupprimerCompteScreen> {
  final TextEditingController _motDePasseController =
  TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _motDePasseController.dispose();
    super.dispose();
  }

  Future<void> _supprimerCompte() async {
    final motDePasse = _motDePasseController.text.trim();

    if (motDePasse.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez saisir votre mot de passe.'),
        ),
      );
      return;
    }

    // Confirmation
    final confirmation = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ?\n\n'
                'Cette action est définitive.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmation != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Récupérer le token de l'utilisateur connecté
      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        throw Exception(
          'Session expirée. Veuillez vous reconnecter.',
        );
      }

      // Appel du backend
      await ApiService.deleteMyAccount(
        token,
        motDePasse,
      );

      // Suppression des informations locales
      await StorageService.clearAll();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte supprimé avec succès.'),
        ),
      );

      // Retour à la connexion
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supprimer mon compte'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),

            const Icon(
              Icons.delete_forever,
              size: 90,
            ),

            const SizedBox(height: 25),

            const Text(
              'Supprimer mon compte',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 15),

            const Text(
              'Cette action est définitive. '
                  'Votre compte sera supprimé de l’application.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: _motDePasseController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Mot de passe',
                hintText: 'Entrez votre mot de passe',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                _isLoading ? null : _supprimerCompte,
                icon: _isLoading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.delete),
                label: Text(
                  _isLoading
                      ? 'Suppression...'
                      : 'Supprimer mon compte',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}