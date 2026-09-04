import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<dynamic> notifications = [];
  bool chargement = true;
  String? erreur;
  bool afficherNotificationsPrecedentes = false;

  @override
  void initState() {
    super.initState();
    chargerNotifications();
  }

  Future<void> chargerNotifications() async {
    try {
      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;
        setState(() {
          erreur = "Utilisateur non connecté";
          chargement = false;
        });
        return;
      }

      final resultat = await ApiService.getNotifications(token);

      if (!mounted) return;

      setState(() {
        // Affiche toutes les notifications, y compris les alertes de seuil configurées par l'admin
        notifications = resultat;
        chargement = false;
      });

      if (notifications.isNotEmpty) {
        await ApiService.markNotificationsAsRead(token);
      }
    } catch (e) {
      debugPrint("ERREUR NOTIFICATIONS : $e");
      if (!mounted) return;
      setState(() {
        erreur = e.toString();
        chargement = false;
      });
    }
  }

  String tempsEcoule(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";
    final date = DateTime.tryParse(dateString);
    if (date == null) return "";

    final dateLocale = date.toLocal();
    final maintenant = DateTime.now();
    final difference = maintenant.difference(dateLocale);

    if (difference.isNegative || difference.inMinutes < 1) return "À l'instant";
    if (difference.inHours < 1) return "Il y a ${difference.inMinutes} min";
    if (difference.inDays < 1) return "Il y a ${difference.inHours} h";

    if (difference.inDays == 1) {
      final heure = dateLocale.hour.toString().padLeft(2, '0');
      final minute = dateLocale.minute.toString().padLeft(2, '0');
      return "Hier à $heure:$minute";
    }

    final jour = dateLocale.day.toString().padLeft(2, '0');
    final mois = dateLocale.month.toString().padLeft(2, '0');
    final annee = dateLocale.year.toString();
    return "$jour/$mois/$annee";
  }

  bool estNotificationRecente(dynamic notification) {
    final dateString = notification["dateCreation"];
    if (dateString == null || dateString.toString().isEmpty) return false;
    final date = DateTime.tryParse(dateString.toString());
    if (date == null) return false;

    final difference = DateTime.now().difference(date.toLocal());
    if (difference.isNegative) return true;
    return difference.inDays <= 1;
  }

  List<dynamic> get notificationsRecentes {
    return notifications.where((n) => estNotificationRecente(n)).toList();
  }

  List<dynamic> get notificationsPrecedentes {
    return notifications.where((n) => !estNotificationRecente(n)).toList();
  }

  Widget _construireNotification(dynamic notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.notifications, color: Colors.blue, size: 20),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    notification["titre"] ?? "Notification",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification["message"] ?? "",
                    style: const TextStyle(fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tempsEcoule(notification["dateCreation"]),
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aucuneNotification() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.notifications_none, color: Colors.blue, size: 70),
          const SizedBox(height: 15),
          const Text("Aucune notification",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      body: _construireContenu(),
    );
  }

  Widget _construireContenu() {
    if (chargement) return const Center(child: CircularProgressIndicator());

    if (erreur != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 55),
              const SizedBox(height: 12),
              Text(erreur!, textAlign: TextAlign.center),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    chargement = true;
                    erreur = null;
                  });
                  chargerNotifications();
                },
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    if (notifications.isEmpty) return _aucuneNotification();

    final recentes = notificationsRecentes;
    final precedentes = notificationsPrecedentes;

    return RefreshIndicator(
      onRefresh: chargerNotifications,
      color: Colors.blue,
      child: Scrollbar(
        thumbVisibility: true,
        thickness: 6,
        radius: const Radius.circular(10),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Plus de padding en bas
          children: [
            if (recentes.isNotEmpty)
              ...recentes.map((n) => _construireNotification(n)),
            if (precedentes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => afficherNotificationsPrecedentes = !afficherNotificationsPrecedentes),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.history, color: Colors.blue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            afficherNotificationsPrecedentes
                                ? "Masquer mes notifications précédentes"
                                : "Voir mes notifications précédentes",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        Icon(
                          afficherNotificationsPrecedentes ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (afficherNotificationsPrecedentes)
              ...precedentes.map((n) => _construireNotification(n)),
          ],
        ),
      ),
    );
  }
}
