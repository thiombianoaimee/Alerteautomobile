import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/storage_service.dart';

class SubscriptionsScreen extends StatefulWidget {
  final UserModel user;

  const SubscriptionsScreen({
    super.key,
    required this.user,
  });

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  List<dynamic> _plansAffiches = [];
  bool _isLoading = true;

  String? _periodiciteRecommandee;

  @override
  void initState() {
    super.initState();
    _fetchTout();
  }

  Future<void> _fetchTout() async {
    try {
      final token = await StorageService.getToken();

      if (token == null) {
        setState(() {
          _plansAffiches = [];
          _isLoading = false;
        });
        return;
      }

      final plans = await ApiService.getActiveSubscriptionPlans(token);

      final recommandation =
      await ApiService.getRecommandationPeriodicite(token);

      final List<String> periodicitesAAfficher =
      List<String>.from(
        recommandation['periodicitesAAfficher'] ?? ['annuel'],
      );

      // Filtre les périodicités autorisées ET exclut les versions PRO/ELITE
      final plansFiltres = plans.where((plan) {
        final String nom = (plan['nom'] ?? '').toString().toLowerCase();
        final bool estVersionPro = nom.contains("pro") || nom.contains("elite");
        
        return periodicitesAAfficher.contains(plan['periodeFacturation']) && !estVersionPro;
      }).toList();

      setState(() {
        _plansAffiches = plansFiltres;

        _periodiciteRecommandee =
        recommandation['periodiciteRecommandee'];

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        "Erreur récupération plans/recommandation : $e",
      );

      setState(() {
        _plansAffiches = [];
        _isLoading = false;
      });
    }
  }

  Color _colorForOrdre(int ordre) {
    switch (ordre) {
      case 1:
        return Colors.grey;

      case 2:
        return Colors.blue;

      default:
        return Colors.blueGrey;
    }
  }

  String _labelPeriode(String? periode) {
    switch (periode) {
      case "semestriel":
        return "/ 6 mois";

      case "annuel":
        return "/ an";

      default:
        return "";
    }
  }

  // ----------------------------------------------------------
  // FONCTIONNALITÉS DES ABONNEMENTS
  // ----------------------------------------------------------

  List<String> _fonctionnalitesPlan(String nomPlan) {
    final nom = nomPlan.toLowerCase();

    // BASIC
    if (nom.contains("basic")) {
      return [
        "Notifications dans l'application",
        "Notifications par email",
      ];
    }

    // PREMIUM
    if (nom.contains("premium")) {
      return [
        "Notifications dans l'application",
        "Notifications par email",
        "Notifications SMS",
        "Prendre rendez-vous",
      ];
    }

    // Si le nom du plan ne correspond pas,
    // on utilise les fonctionnalités venant du backend.
    return [];
  }

  // ----------------------------------------------------------
  // INTERFACE PRINCIPALE
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir un Abonnement"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "Boostez votre expérience",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Choisissez le plan qui correspond le mieux à vos besoins d'entretien automobile.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            _plansAffiches.isEmpty
                ? const Padding(
              padding: EdgeInsets.symmetric(
                vertical: 40,
              ),
              child: Text(
                "Aucun plan disponible pour le moment.",
              ),
            )
                : SizedBox(
              height: 520,
              child: PageView.builder(
                controller: PageController(
                  viewportFraction: 0.85,
                ),
                itemCount: _plansAffiches.length,
                itemBuilder: (context, index) {
                  final plan =
                  _plansAffiches[index];

                  return _buildPlanCard(plan);
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // CARTE ABONNEMENT
  // ----------------------------------------------------------

  Widget _buildPlanCard(dynamic plan) {
    final String nomPlan =
    (plan['nomAffiche'] ??
        plan['nom'] ??
        '')
        .toString();

    final Color color =
    _colorForOrdre(plan['ordre'] ?? 0);

    final String periode =
        plan['periodeFacturation'] ?? '';

    final bool estRecommande =
        periode == _periodiciteRecommandee;

    // Fonctionnalités personnalisées
    final List<String> fonctionnalites =
    _fonctionnalitesPlan(nomPlan);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: estRecommande
              ? Colors.green
              : color.withValues(alpha: 0.3),
          width: estRecommande ? 3 : 2,
        ),
      ),
      child: Column(
        children: [
          // --------------------------------------------------
          // RECOMMANDÉ
          // --------------------------------------------------

          if (estRecommande)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 6,
              ),
              decoration: const BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(23),
                  topRight: Radius.circular(23),
                ),
              ),
              child: const Text(
                "RECOMMANDÉ POUR VOUS",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),

          // --------------------------------------------------
          // EN-TÊTE DU PLAN
          // --------------------------------------------------

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              vertical: 25,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius: estRecommande
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            child: Column(
              children: [
                Text(
                  nomPlan.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${plan['prix']} FCFA",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 32,
                  ),
                ),

                Text(
                  _labelPeriode(periode),
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // --------------------------------------------------
          // FONCTIONNALITÉS
          // --------------------------------------------------

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  if (plan['description'] != null &&
                      plan['description']
                          .toString()
                          .trim()
                          .isNotEmpty)
                    Text(
                      plan['description'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),

                  const SizedBox(height: 15),

                  ...fonctionnalites.map(
                        (fonctionnalite) {
                      return Padding(
                        padding:
                        const EdgeInsets.symmetric(
                          vertical: 8.0,
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fonctionnalite,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // --------------------------------------------------
          // BOUTON
          // --------------------------------------------------

          Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  // Logique de paiement
                  // à implémenter plus tard
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "SOUSCRIRE MAINTENANT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}