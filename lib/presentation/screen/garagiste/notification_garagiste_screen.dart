import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class NotificationsGaragisteScreen extends StatefulWidget {
  const NotificationsGaragisteScreen({super.key});

  @override
  State<NotificationsGaragisteScreen> createState() => _NotificationsGaragisteScreenState();
}

class _NotificationsGaragisteScreenState extends State<NotificationsGaragisteScreen> {
  List<dynamic> notifications = [];
  bool chargement = true;
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
        setState(() => chargement = false);
        return;
      }
      final data = await ApiService.getNotifications(token);
      if (!mounted) return;
      setState(() {
        notifications = data;
        chargement = false;
      });
      if (notifications.isNotEmpty) {
        await ApiService.markNotificationsAsRead(token);
      }
    } catch (e) {
      debugPrint("Erreur notifications garagiste : $e");
      if (!mounted) return;
      setState(() => chargement = false);
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
      return "Hier à ${dateLocale.hour.toString().padLeft(2, '0')}:${dateLocale.minute.toString().padLeft(2, '0')}";
    }
    return "${dateLocale.day.toString().padLeft(2, '0')}/${dateLocale.month.toString().padLeft(2, '0')}/${dateLocale.year}";
  }

  bool estNotificationRecente(dynamic notification) {
    final dateString = notification["dateCreation"];
    if (dateString == null || dateString.isEmpty) return true;
    final date = DateTime.tryParse(dateString);
    if (date == null) return true;
    final difference = DateTime.now().difference(date.toLocal());
    return difference.isNegative || difference.inDays < 2;
  }

  List<dynamic> get notificationsRecentes => notifications.where((n) => estNotificationRecente(n)).toList();
  List<dynamic> get notificationsPrecedentes => notifications.where((n) => !estNotificationRecente(n)).toList();

  Widget _notificationCard(dynamic notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.notifications, color: Colors.blue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification["titre"] ?? "Notification",
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    notification["message"] ?? "",
                    style: const TextStyle(fontSize: 15, height: 1.4),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tempsEcoule(notification["dateCreation"]),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
          Icon(Icons.notifications_none, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 20),
          const Text("Aucune notification", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notifications"), centerTitle: true),
      body: chargement
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? _aucuneNotification()
              : _construireListe(),
    );
  }

  Widget _construireListe() {
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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            if (recentes.isNotEmpty) ...recentes.map((n) => _notificationCard(n)),
            if (precedentes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
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
                            afficherNotificationsPrecedentes ? "Masquer mes notifications précédentes" : "Voir mes notifications précédentes",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                        ),
                        Icon(afficherNotificationsPrecedentes ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: Colors.blue),
                      ],
                    ),
                  ),
                ),
              ),
            if (afficherNotificationsPrecedentes) ...precedentes.map((n) => _notificationCard(n)),
          ],
        ),
      ),
    );
  }
}
