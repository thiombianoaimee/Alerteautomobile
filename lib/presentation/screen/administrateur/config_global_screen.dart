import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';

class ConfigGlobalSubscriptionScreen extends StatefulWidget {
  final UserModel user;

  const ConfigGlobalSubscriptionScreen({super.key, required this.user});

  @override
  State<ConfigGlobalSubscriptionScreen> createState() => _ConfigGlobalSubscriptionScreenState();
}

class _ConfigGlobalSubscriptionScreenState extends State<ConfigGlobalSubscriptionScreen> {
  final _trialController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  Future<void> _fetchConfig() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        setState(() {
          _trialController.text = "7";
          _isLoading = false;
        });
        return;
      }
      final config = await ApiService.getGlobalSubscriptionConfig(token);
      setState(() {
        _trialController.text = (config['dureeEssaiJours'] ?? 7).toString();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _trialController.text = "7"; // Fallback default
        _isLoading = false;
      });
    }
  }

  Future<void> _saveConfig() async {
    final days = int.tryParse(_trialController.text.trim());
    if (days == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Veuillez entrer un nombre de jours valide")),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        await ApiService.updateGlobalSubscriptionConfig(token, {"dureeEssaiJours": days});
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Configuration enregistrée"), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Configuration Globale")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Paramètres des Abonnements",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.timer, color: Colors.blue),
                              SizedBox(width: 10),
                              Text("Période d'essai (Trial)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text(
                            "Nombre de jours gratuits offerts à l'inscription d'un nouvel automobiliste.",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 15),
                          TextField(
                            controller: _trialController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: "Durée du trial (en jours)",
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              suffixText: "Jours",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveConfig,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("ENREGISTRER LES MODIFICATIONS", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
