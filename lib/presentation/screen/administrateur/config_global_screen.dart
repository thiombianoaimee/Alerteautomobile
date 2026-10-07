import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';
  import 'profil_admin_screen.dart';

class ConfigGlobalSubscriptionScreen extends StatefulWidget {
  final UserModel user;
  final bool showAppBar;

  const ConfigGlobalSubscriptionScreen({
    super.key,
    required this.user,
    this.showAppBar = true,
  });

  @override
  State<ConfigGlobalSubscriptionScreen> createState() =>
      _ConfigGlobalSubscriptionScreenState();
}

class _ConfigGlobalSubscriptionScreenState
    extends State<ConfigGlobalSubscriptionScreen> {
  final _trialController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchConfig();
  }

  @override
  void dispose() {
    _trialController.dispose();
    super.dispose();
  }

  Future<void> _fetchConfig() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      int? cachedDays = prefs.getInt('cached_duree_trial');

      final token = await StorageService.getToken();
      if (token != null) {
        final res = await ApiService.getGlobalSubscriptionConfig(token);
        debugPrint("RESPONSE CONFIG GET: $res");

        final Map<String, dynamic> config = (res['config'] is Map)
            ? res['config']
            : (res['data'] is Map)
                ? res['data']
                : (res['configuration'] is Map)
                    ? res['configuration']
                    : res;

        final rawTrial = config['dureeEssaiJours'] ??
            config['dureeTrial'] ??
            config['dureeEssai'] ??
            config['duree_essai'] ??
            config['trialDays'] ??
            config['duree'] ??
            config['periodeEssai'] ??
            config['days'];

        int trialDays = 0;
        if (rawTrial != null) {
          trialDays = int.tryParse(rawTrial.toString()) ?? 0;
        }

        if (trialDays == 0 && cachedDays != null && cachedDays > 0) {
          trialDays = cachedDays;
        } else if (trialDays > 0) {
          await prefs.setInt('cached_duree_trial', trialDays);
        }

        _trialController.text = trialDays.toString();
      } else if (cachedDays != null) {
        _trialController.text = cachedDays.toString();
      }
    } catch (e) {
      debugPrint("Erreur chargement config global: $e");
      try {
        final prefs = await SharedPreferences.getInstance();
        int? cachedDays = prefs.getInt('cached_duree_trial');
        if (cachedDays != null) {
          _trialController.text = cachedDays.toString();
        }
      } catch (_) {}
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveConfig() async {
    final days = int.tryParse(_trialController.text.trim());
    if (days == null || days < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez entrer un nombre de jours valide"),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('cached_duree_trial', days);

      final token = await StorageService.getToken();
      if (token != null) {
        await ApiService.updateGlobalSubscriptionConfig(token, {
          'dureeEssaiJours': days,
          'dureeTrial': days,
          'dureeEssai': days,
          'duree_essai': days,
          'trialDays': days,
          'duree': days,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Configuration enregistrée avec succès !"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'enregistrement : ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = _isLoading
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
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.timer, color: Colors.blue),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Période d'essai (Trial)",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
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
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "ENREGISTRER LES MODIFICATIONS",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );

    if (!widget.showAppBar) return content;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Configuration Globale"),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilAdminScreen(user: widget.user),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0, left: 5.0),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF00838F),
                child: Text(
                  widget.user.nom.trim().isNotEmpty
                      ? widget.user.nom.trim()[0].toUpperCase()
                      : 'A',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: content,
    );
  }
}
