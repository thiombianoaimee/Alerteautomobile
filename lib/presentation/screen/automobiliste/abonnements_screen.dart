import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/storage_service.dart';
import 'profil_auto_screen.dart';
import 'notifications_screen.dart';

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
  Map<String, dynamic>? _monAbonnementActif;
  bool _isLoading = true;

  String? _periodiciteRecommandee;

  @override
  void initState() {
    super.initState();
    _fetchTout();
  }

  // ==========================================================
  // SOUSCRIPTION
  // ==========================================================

  Future<void> _souscrire(dynamic plan) async {
    final planId = plan['_id']?.toString();

    if (planId == null) return;

    final nomPlan =
    (plan['nomAffiche'] ?? plan['nom'] ?? 'Abonnement').toString();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final token = await StorageService.getToken();

      if (token == null) {
        throw Exception("Utilisateur non connecté.");
      }

      final resultat =
      await ApiService.souscrireAbonnement(token, planId);

      if (!mounted) return;

      // Ferme le chargement
      Navigator.pop(context);

      final message = resultat["message"] ??
          "Votre souscription au plan $nomPlan a été effectuée avec succès !";

      // ======================================================
      // DIALOGUE PAIEMENT RÉUSSI
      // ======================================================

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 60,
          ),
          title: const Text(
            "Paiement Réussi !",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Votre abonnement est désormais actif.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 12,
                ),
              ),
              onPressed: () async {
                Navigator.pop(ctx);

                // Actualise les informations d'abonnement
                await _fetchTout();
              },
              child: const Text(
                "Continuer",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;

      // Ferme le dialogue de chargement
      Navigator.pop(context);

      final errorMsg =
      e.toString().replaceFirst("Exception: ", "");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // ==========================================================
  // RÉCUPÉRATION DES PLANS + ABONNEMENT
  // ==========================================================

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

      final results = await Future.wait([
        ApiService.getActiveSubscriptionPlans(token),
        ApiService.getRecommandationPeriodicite(token),
        ApiService.getMySubscriptionStatus(token).catchError(
              (_) => <String, dynamic>{},
        ),
      ]);

      final plans = results[0] as List<dynamic>;

      final recommandation =
      results[1] as Map<String, dynamic>;

      final mySub =
      results[2] as Map<String, dynamic>;

      final List<String> periodicitesAAfficher =
      List<String>.from(
        recommandation['periodicitesAAfficher'] ??
            ['annuel'],
      );

      // ======================================================
      // FILTRE DES PLANS
      // ======================================================

      final plansFiltres = plans.where((plan) {
        final String nom =
        (plan['nom'] ?? '').toString().toLowerCase();

        final bool estVersionPro =
            nom.contains("pro") || nom.contains("elite");

        return periodicitesAAfficher.contains(
          plan['periodeFacturation'],
        ) &&
            !estVersionPro;
      }).toList();

      if (!mounted) return;

      setState(() {
        _plansAffiches = plansFiltres;

        _periodiciteRecommandee =
        recommandation['periodiciteRecommandee'];

        _monAbonnementActif = mySub;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint(
        "Erreur récupération plans/recommandation : $e",
      );

      if (!mounted) return;

      setState(() {
        _plansAffiches = [];
        _isLoading = false;
      });
    }
  }

  // ==========================================================
  // COULEUR SELON LE PLAN
  // ==========================================================

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

  // ==========================================================
  // LIBELLÉ DE LA PÉRIODE
  // ==========================================================

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

  // ==========================================================
  // FONCTIONNALITÉS DES ABONNEMENTS
  // ==========================================================

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

    return [];
  }

  // ==========================================================
  // INTERFACE PRINCIPALE
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir un Abonnement"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: "Notifications",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const NotificationsScreen(),
                ),
              );
            },
          ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProfilAutoScreen(
                        user: widget.user,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(
                right: 15.0,
                left: 5.0,
              ),
              child: CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF00838F),
                child: Text(
                  widget.user.nom.trim().isNotEmpty
                      ? widget.user.nom
                      .trim()[0]
                      .toUpperCase()
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

            // ==================================================
            // PLANS
            // ==================================================

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
              height: 540,
              child: PageView.builder(
                controller: PageController(
                  viewportFraction: 0.85,
                ),
                itemCount:
                _plansAffiches.length,
                itemBuilder:
                    (context, index) {
                  final plan =
                  _plansAffiches[index];

                  return _buildPlanCard(
                    plan,
                  );
                },
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // CARTE ABONNEMENT
  // ==========================================================

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

    final List<String> fonctionnalites =
    _fonctionnalitesPlan(nomPlan);

    // ========================================================
    // ABONNEMENT ACTUEL
    // ========================================================

    final String? statutActuel =
    _monAbonnementActif?['statut']
        ?.toString()
        .toLowerCase();

    final bool estAbonnementActif =
        statutActuel == 'actif';

    final dynamic planActuel =
    _monAbonnementActif?['plan'];

    final String? planActuelId =
    planActuel is Map
        ? planActuel['_id']?.toString()
        : _monAbonnementActif?['planId']
        ?.toString();

    final String planActuelNom =
    (planActuel is Map
        ? (planActuel['nomAffiche'] ??
        planActuel['nom'] ??
        '')
        : '')
        .toString()
        .toLowerCase();

    final String targetId =
        plan['_id']?.toString() ?? '';

    final String targetNom =
    nomPlan.toLowerCase();

    // ========================================================
    // IDENTIFICATION DU MÊME PLAN
    // ========================================================

    final bool estMemePlan =
        estAbonnementActif &&
            (
                (
                    targetId.isNotEmpty &&
                        planActuelId != null &&
                        targetId == planActuelId
                ) ||
                    (
                        planActuelNom.isNotEmpty &&
                            (
                                targetNom.contains(planActuelNom) ||
                                    planActuelNom.contains(targetNom)
                            )
                    )
            );

    // ========================================================
    // TEXTE DU BOUTON
    // ========================================================

    String buttonLabel =
        "SOUSCRIRE MAINTENANT";

    if (estAbonnementActif && estMemePlan) {
      // Même plan = renouvellement autorisé
      buttonLabel = "RENOUVELER";
    } else if (estAbonnementActif) {
      // Autre plan = changement de plan
      buttonLabel = "CHOISIR CE PLAN";
    }

    // ========================================================
    // CARTE
    // ========================================================

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color:
            color.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: estRecommande
              ? Colors.green
              : color.withValues(alpha: 0.3),
          width:
          estRecommande ? 3 : 2,
        ),
      ),
      child: Column(
        children: [
          // ==================================================
          // BADGE RECOMMANDÉ
          // ==================================================

          if (estRecommande)
            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(
                vertical: 6,
              ),
              decoration:
              const BoxDecoration(
                color: Colors.green,
                borderRadius:
                BorderRadius.only(
                  topLeft:
                  Radius.circular(23),
                  topRight:
                  Radius.circular(23),
                ),
              ),
              child: const Text(
                "RECOMMANDÉ POUR VOUS",
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 11,
                  letterSpacing: 1,
                ),
              ),
            ),

          // ==================================================
          // EN-TÊTE DU PLAN
          // ==================================================

          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(
              vertical: 25,
            ),
            decoration: BoxDecoration(
              color: color,
              borderRadius:
              estRecommande
                  ? BorderRadius.zero
                  : const BorderRadius.only(
                topLeft:
                Radius.circular(
                    23),
                topRight:
                Radius.circular(
                    23),
              ),
            ),
            child: Column(
              children: [
                Text(
                  nomPlan.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 20,
                    letterSpacing: 2,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  "${plan['prix']} FCFA",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                    FontWeight.bold,
                    fontSize: 32,
                  ),
                ),

                Text(
                  _labelPeriode(
                    periode,
                  ),
                  style:
                  const TextStyle(
                    color:
                    Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          // ==================================================
          // DESCRIPTION + FONCTIONNALITÉS
          // ==================================================

          Expanded(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
              child:
              SingleChildScrollView(
                physics:
                const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    if (plan['description'] !=
                        null &&
                        plan['description']
                            .toString()
                            .trim()
                            .isNotEmpty)
                      Text(
                        plan['description'],
                        textAlign:
                        TextAlign.center,
                        style:
                        const TextStyle(
                          fontStyle:
                          FontStyle.italic,
                          color:
                          Colors.grey,
                        ),
                      ),

                    const SizedBox(
                      height: 15,
                    ),

                    ...fonctionnalites.map(
                          (fonctionnalite) {
                        return Padding(
                          padding:
                          const EdgeInsets
                              .symmetric(
                            vertical: 8.0,
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Icon(
                                Icons
                                    .check_circle,
                                color: color,
                                size: 20,
                              ),

                              const SizedBox(
                                width: 12,
                              ),

                              Expanded(
                                child: Text(
                                  fonctionnalite,
                                  style:
                                  const TextStyle(
                                    fontSize: 15,
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
          ),

          // ==================================================
          // BOUTON
          // ==================================================

          Padding(
            padding:
            const EdgeInsets.all(20.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                // ==================================================
                // LE MÊME PLAN PEUT ÊTRE RENOUVELÉ
                // ==================================================

                onPressed: () =>
                    _souscrire(plan),

                style:
                ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                        15),
                  ),
                ),

                child: Text(
                  buttonLabel,
                  style:
                  const TextStyle(
                    fontWeight:
                    FontWeight.bold,
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