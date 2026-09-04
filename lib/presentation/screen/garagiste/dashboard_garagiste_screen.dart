import 'package:flutter/material.dart';
import '../../../metier/models/user_model.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import 'creneaux_screen.dart';
import 'demandes_screen.dart';
import 'mes_rendezvous_screen.dart';
import 'profil_garagiste_screen.dart';
import 'notification_garagiste_screen.dart';

class DashboardGaragisteScreen extends StatefulWidget {
  final UserModel user;

  const DashboardGaragisteScreen({
    super.key,
    required this.user,
  });

  @override
  State<DashboardGaragisteScreen> createState() => _DashboardGaragisteScreenState();
}

class _DashboardGaragisteScreenState extends State<DashboardGaragisteScreen> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchNotificationCount();
  }

  Future<void> _fetchNotificationCount() async {
    try {
      final token = await StorageService.getToken();
      debugPrint("TOKEN GARAGISTE: $token");
      if (token != null) {
        final count = await ApiService.getUnreadNotificationsCount(token);
        if (!mounted) return;
        setState(() {
          _unreadCount = count;
        });
      }
    } catch (e) {
      debugPrint("Erreur notifications garagiste dashboard: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon espace Garagiste"),
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
                    builder: (context) => const NotificationsGaragisteScreen(),
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
                    builder: (context) => const NotificationsGaragisteScreen(),
                  ),
                );
                _fetchNotificationCount();
              },
            ),
          IconButton(
            icon: const Icon(Icons.account_circle, size: 30),
            tooltip: "Mon profil",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfilGaragisteScreen(user: widget.user),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Bienvenue, ${widget.user.nom}",
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Gérez vos disponibilités et vos demandes de rendez-vous.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView(
                children: [
                  _menuCard(
                    context,
                    Icons.schedule,
                    "Gérer mes disponibilités",
                    CreneauxScreen(user: widget.user),
                    Colors.blue,
                  ),
                  _menuCard(
                    context,
                    Icons.calendar_month,
                    "Gérer les demandes de rendez-vous",
                    DemandesScreen(user: widget.user),
                    Colors.green,
                  ),
                  _menuCard(
                    context,
                    Icons.event_note,
                    "Mes rendez-vous confirmés",
                    MesRendezVousGaragisteScreen(user: widget.user),
                    Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuCard(BuildContext context, IconData icon, String title,
      Widget page, Color color) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Card(
          elevation: 5,
          margin: const EdgeInsets.only(bottom: 15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: SizedBox(
            height: 85,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: color.withValues(alpha: 0.15),
                    child: Icon(icon, size: 30, color: color),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 18, color: Colors.grey),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
