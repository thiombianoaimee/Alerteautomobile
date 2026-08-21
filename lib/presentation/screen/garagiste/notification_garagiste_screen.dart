import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class NotificationsGaragisteScreen extends StatefulWidget {
  const NotificationsGaragisteScreen({super.key});

  @override
  State<NotificationsGaragisteScreen> createState() =>
      _NotificationsGaragisteScreenState();
}

class _NotificationsGaragisteScreenState
    extends State<NotificationsGaragisteScreen> {

  List<dynamic> notifications = [];

  bool chargement = true;

  bool afficherNotificationsPrecedentes = false;

  @override
  void initState() {
    super.initState();
    chargerNotifications();
  }

  // =====================================================
  // CHARGER LES NOTIFICATIONS
  // =====================================================

  Future<void> chargerNotifications() async {
    try {
      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        if (!mounted) return;

        setState(() {
          chargement = false;
        });

        return;
      }

      final data =
      await ApiService.getNotifications(token);

      if (!mounted) return;

      setState(() {
        notifications = data;
        chargement = false;
      });
    } catch (e) {
      debugPrint(
        "Erreur notifications garagiste : $e",
      );

      if (!mounted) return;

      setState(() {
        chargement = false;
      });
    }
  }

  // =====================================================
  // TEMPS ÉCOULÉ
  // =====================================================

  String tempsEcoule(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return "";
    }

    final date = DateTime.tryParse(dateString);

    if (date == null) {
      return "";
    }

    final dateLocale = date.toLocal();

    final maintenant = DateTime.now();

    final difference =
    maintenant.difference(dateLocale);

    // =====================================================
    // DATE FUTURE
    // =====================================================

    if (difference.isNegative) {
      return "À l'instant";
    }

    // =====================================================
    // MOINS D'UNE MINUTE
    // =====================================================

    if (difference.inMinutes < 1) {
      return "À l'instant";
    }

    // =====================================================
    // MOINS D'UNE HEURE
    // =====================================================

    if (difference.inHours < 1) {
      return "Il y a ${difference.inMinutes} min";
    }

    // =====================================================
    // MOINS DE 24 HEURES
    // =====================================================

    if (difference.inDays < 1) {
      return "Il y a ${difference.inHours} h";
    }

    // Heure et minute
    final heure =
    dateLocale.hour
        .toString()
        .padLeft(2, '0');

    final minute =
    dateLocale.minute
        .toString()
        .padLeft(2, '0');

    // =====================================================
    // HIER
    // =====================================================

    if (difference.inDays == 1) {
      return "Hier à $heure:$minute";
    }

    // =====================================================
    // À PARTIR DE 2 JOURS
    // DATE COMPLÈTE
    // =====================================================

    final jour =
    dateLocale.day
        .toString()
        .padLeft(2, '0');

    final mois =
    dateLocale.month
        .toString()
        .padLeft(2, '0');

    final annee =
    dateLocale.year.toString();

    return "$jour/$mois/$annee";
  }

  // =====================================================
  // NOTIFICATION RÉCENTE
  // =====================================================

  bool estNotificationRecente(
      dynamic notification) {

    final dateString =
    notification["dateCreation"];

    if (dateString == null ||
        dateString.isEmpty) {
      return true;
    }

    final date =
    DateTime.tryParse(dateString);

    if (date == null) {
      return true;
    }

    final difference =
    DateTime.now()
        .difference(date.toLocal());

    // Une date future reste récente
    if (difference.isNegative) {
      return true;
    }

    // =====================================================
    // MOINS DE 2 JOURS = RÉCENTE
    // =====================================================

    return difference.inDays < 2;
  }

  // =====================================================
  // NOTIFICATIONS RÉCENTES
  // =====================================================

  List<dynamic> get notificationsRecentes {
    return notifications
        .where(
          (notification) =>
          estNotificationRecente(
            notification,
          ),
    )
        .toList();
  }

  // =====================================================
  // NOTIFICATIONS PRÉCÉDENTES
  // =====================================================

  List<dynamic> get notificationsPrecedentes {
    return notifications
        .where(
          (notification) =>
      !estNotificationRecente(
        notification,
      ),
    )
        .toList();
  }

  // =====================================================
  // CARTE NOTIFICATION
  // =====================================================

  Widget _notificationCard(
      dynamic notification) {

    return Card(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(15),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // =================================================
            // ICÔNE
            // =================================================

            Container(
              padding:
              const EdgeInsets.all(8),
              decoration:
              BoxDecoration(
                color:
                Colors.blue.withValues(
                  alpha: 0.10,
                ),
                shape:
                BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications,
                color: Colors.blue,
                size: 22,
              ),
            ),

            const SizedBox(width: 14),

            // =================================================
            // CONTENU
            // =================================================

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // =================================================
                  // TITRE
                  // =================================================

                  Text(
                    notification["titre"] ??
                        "Notification",
                    style:
                    const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // =================================================
                  // MESSAGE
                  // =================================================

                  Text(
                    notification["message"] ??
                        "",
                    style:
                    const TextStyle(
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // =================================================
                  // DATE
                  // =================================================

                  Text(
                    tempsEcoule(
                      notification[
                      "dateCreation"],
                    ),
                    style:
                    const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  // =====================================================
  // AUCUNE NOTIFICATION
  // =====================================================

  Widget _aucuneNotification() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [

          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 20),

          const Text(
            "Aucune notification",
            style: TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Notifications",
        ),
        centerTitle: true,
      ),

      body: chargement

      // =================================================
      // CHARGEMENT
      // =================================================

          ? const Center(
        child:
        CircularProgressIndicator(),
      )

      // =================================================
      // AUCUNE NOTIFICATION
      // =================================================

          : notifications.isEmpty

          ? _aucuneNotification()

      // =================================================
      // LISTE
      // =================================================

          : _construireListe(),
    );
  }

  // =====================================================
  // CONSTRUIRE LA LISTE
  // =====================================================

  Widget _construireListe() {

    final recentes =
        notificationsRecentes;

    final precedentes =
        notificationsPrecedentes;

    return RefreshIndicator(
      onRefresh:
      chargerNotifications,

      child: ListView(
        padding:
        const EdgeInsets.all(16),

        physics:
        const AlwaysScrollableScrollPhysics(),

        children: [

          // =================================================
          // NOTIFICATIONS RÉCENTES
          // =================================================

          if (recentes.isNotEmpty)

            ...recentes.map(
                  (notification) =>
                  _notificationCard(
                    notification,
                  ),
            ),

          // =================================================
          // BOUTON NOTIFICATIONS PRÉCÉDENTES
          // =================================================

          if (precedentes.isNotEmpty)

            Padding(
              padding:
              const EdgeInsets.only(
                top: 5,
                bottom: 15,
              ),

              child: InkWell(
                borderRadius:
                BorderRadius.circular(12),

                onTap: () {
                  setState(() {
                    afficherNotificationsPrecedentes =
                    !afficherNotificationsPrecedentes;
                  });
                },

                child: Container(
                  padding:
                  const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 15,
                  ),

                  decoration:
                  BoxDecoration(
                    color:
                    Colors.blue.withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                    BorderRadius.circular(12),
                  ),

                  child: Row(
                    children: [

                      const Icon(
                        Icons.history,
                        color: Colors.blue,
                      ),

                      const SizedBox(
                        width: 10,
                      ),

                      Expanded(
                        child: Text(
                          afficherNotificationsPrecedentes
                              ? "Masquer mes notifications précédentes"
                              : "Voir mes notifications précédentes",

                          style:
                          const TextStyle(
                            fontSize: 14,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            Colors.blue,
                          ),
                        ),
                      ),

                      Icon(
                        afficherNotificationsPrecedentes
                            ? Icons
                            .keyboard_arrow_up
                            : Icons
                            .keyboard_arrow_down,
                        color:
                        Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // =================================================
          // NOTIFICATIONS PRÉCÉDENTES
          // =================================================

          if (afficherNotificationsPrecedentes)

            ...precedentes.map(
                  (notification) =>
                  _notificationCard(
                    notification,
                  ),
            ),
        ],
      ),
    );
  }
}