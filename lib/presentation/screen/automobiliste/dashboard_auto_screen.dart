import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import 'profil_auto_screen.dart';
import 'vehicules_screen.dart';
import 'notifications_screen.dart';
import 'rendezvous_screen.dart';
import 'suivi_auto_screen.dart';
import 'abonnements_screen.dart';

class DashboardAutoScreen extends StatefulWidget {
  final UserModel user;

  const DashboardAutoScreen({
    super.key,
    required this.user,
  });

  @override
  State<DashboardAutoScreen> createState() => _DashboardAutoScreenState();
}

class _DashboardAutoScreenState extends State<DashboardAutoScreen> {
  int _unreadCount = 0;
  String? _statutAlerte; // "alerte" ou "expire" (null = rien à afficher)
  String? _messageAlerte;
  List<String>? _fonctionnalites; // null = pas encore chargé ou erreur

  @override
  void initState() {
    super.initState();
    _rafraichirDonnees();
  }

  Future<void> _rafraichirDonnees() async {
    await Future.wait([
      _fetchFonctionnalites(),
      _fetchSubscriptionStatus(),
      _fetchNotificationCount(),
    ]);
  }

  Future<void> _fetchFonctionnalites() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return;

      final fonc = await ApiService.getMesFonctionnalites(token);
      if (!mounted) return;
      setState(() {
        _fonctionnalites = fonc;
      });
    } catch (e) {
      debugPrint("Erreur fonctionnalités dashboard: $e");
    }
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final token = await StorageService.getToken();
      debugPrint("TOKEN RECUPERE: $token");
      if (token != null) {
        final count = await ApiService.getUnreadNotificationsCount(token);
        if (!mounted) return;
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint("Erreur notifications automobiliste dashboard: $e");
    }
  }

  Future<void> _fetchSubscriptionStatus() async {
    try {
      final token = await StorageService.getToken();
      if (token == null) return;

      final data = await ApiService.getMySubscriptionStatus(token);
      if (!mounted) return;
      setState(() {
        _statutAlerte = data["statutAlerte"];
        _messageAlerte = data["messageAlerte"];
      });
    } catch (e) {
      debugPrint("Erreur récupération statut abonnement: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon suivi automobile"),
        centerTitle: true,
        actions: [
          // On n'affiche le badge que si le compte est > 0
          if (_unreadCount > 0)
            IconButton(
              icon: Badge(
                label: Text(_unreadCount.toString()),
                child: const Icon(Icons.notifications),
              ),
              tooltip: "Notifications",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
                _fetchNotificationCount();
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.notifications),
              tooltip: "Notifications",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
                _fetchNotificationCount();
              },
            ),
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilAutoScreen(user: widget.user),
                ),
              );
              _rafraichirDonnees();
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
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue, ${widget.user.nom} ",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Gérez vos véhicules et vos rendez-vous facilement.",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            _bandeauAlerteAbonnement(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView(
                children: [
                  _menuCard(
                    context,
                    Icons.directions_car,
                    "Enregistrer ses véhicules",
                    VehiculesScreen(user: widget.user),
                    Colors.blue,
                    onRetour: _rafraichirDonnees,
                  ),
                  _menuCard(
                    context,
                    Icons.calendar_month,
                    " Prendre rendez-vous",
                    RendezVousScreen(user: widget.user),
                    Colors.green,
                    active: _fonctionnalites == null ||
                        _fonctionnalites!.contains("prise_rdv"),
                    onRetour: _rafraichirDonnees,
                  ),
                  _menuCard(
                    context,
                    Icons.card_membership,
                    "Mon Abonnement",
                    SubscriptionsScreen(user: widget.user),
                    Colors.orange,
                    onRetour: _rafraichirDonnees,
                  ),
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.blue.shade100,
                        child: const Icon(
                          Icons.directions_car,
                          color: Colors.blue,
                        ),
                      ),
                      title: const Text(
                        "Mon espace de suivi automobile",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.grey,
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuiviAutomobilisteScreen(
                              user: widget.user,
                            ),
                          ),
                        );
                        await _rafraichirDonnees();
                      },
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bandeauAlerteAbonnement() {
    if (_messageAlerte == null || _messageAlerte!.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool expire = _statutAlerte == "expire";
    final Color couleurFond = expire ? Colors.red[50]! : Colors.orange[50]!;
    final Color couleurBordure = expire ? Colors.red[200]! : Colors.orange[200]!;
    final Color couleurTexte = expire ? Colors.red : Colors.orange[800]!;
    final IconData icone =
        expire ? Icons.error_outline : Icons.warning_amber_rounded;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubscriptionsScreen(user: widget.user),
          ),
        );
        await _rafraichirDonnees();
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: couleurFond,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: couleurBordure),
        ),
        child: Row(
          children: [
            Icon(icone, color: couleurTexte),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _messageAlerte!,
                style: TextStyle(
                    color: couleurTexte, fontWeight: FontWeight.w600),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 14, color: couleurTexte),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(
    BuildContext context,
    IconData icon,
    String title,
    Widget page,
    Color color, {
    bool badge = false,
    bool active = true,
    Future<void> Function()? onRetour,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: active ? value : value * 0.5,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: active
            ? () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => page,
                  ),
                );
                await onRetour?.call();
              }
            : () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text(
                        "Votre abonnement ne permet pas d'accéder à cette fonctionnalité."),
                    backgroundColor: Colors.orange,
                    action: SnackBarAction(
                      label: "VOIR LES OFFRES",
                      textColor: Colors.white,
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                SubscriptionsScreen(user: widget.user),
                          ),
                        );
                        await _rafraichirDonnees();
                      },
                    ),
                  ),
                );
              },
        child: Card(
          elevation: active ? 5 : 1,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: SizedBox(
            height: 85,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundColor: active
                            ? color.withValues(alpha: 0.15)
                            : Colors.grey.withValues(alpha: 0.2),
                        child: Icon(
                          icon,
                          size: 30,
                          color: active ? color : Colors.grey,
                        ),
                      ),
                      if (badge)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 15,
                            height: 15,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 20),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
