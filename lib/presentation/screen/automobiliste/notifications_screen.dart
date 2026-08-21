import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
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

  // =====================================================
  // CHARGER LES NOTIFICATIONS
  // =====================================================

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

      final resultat =
      await ApiService.getNotifications(token);

      if (!mounted) return;

      setState(() {
        notifications = resultat;
        chargement = false;
      });
    } catch (e) {
      debugPrint("ERREUR NOTIFICATIONS : $e");

      if (!mounted) return;

      setState(() {
        erreur = e.toString();
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

    // Sécurité si la date est dans le futur
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

    // =====================================================
    // HIER
    // =====================================================

    if (difference.inDays == 1) {
      final heure =
      dateLocale.hour.toString().padLeft(2, '0');

      final minute =
      dateLocale.minute.toString().padLeft(2, '0');

      return "Hier à $heure:$minute";
    }

    // =====================================================
    // À PARTIR DE 2 JOURS
    // DATE COMPLÈTE
    // =====================================================

    final jour =
    dateLocale.day.toString().padLeft(2, '0');

    final mois =
    dateLocale.month.toString().padLeft(2, '0');

    final annee =
    dateLocale.year.toString();

    return "$jour/$mois/$annee";
  }

  // =====================================================
  // NOTIFICATION RÉCENTE
  // =====================================================
  //
  // 0 jour = aujourd'hui
  // 1 jour = hier
  //
  // Donc :
  // aujourd'hui + hier => notification principale
  // 2 jours et plus => précédente
  // =====================================================

  bool estNotificationRecente(
      dynamic notification) {

    final dateString =
    notification["dateCreation"];

    if (dateString == null ||
        dateString.toString().isEmpty) {
      return false;
    }

    final date =
    DateTime.tryParse(dateString.toString());

    if (date == null) {
      return false;
    }

    final dateLocale = date.toLocal();
    final maintenant = DateTime.now();

    final difference =
    maintenant.difference(dateLocale);

    if (difference.isNegative) {
      return true;
    }

    return difference.inDays <= 1;
  }

  // =====================================================
  // NOTIFICATIONS RÉCENTES
  // =====================================================

  List<dynamic> get notificationsRecentes {
    return notifications
        .where(
          (notification) =>
          estNotificationRecente(notification),
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
      !estNotificationRecente(notification),
    )
        .toList();
  }

  // =====================================================
  // CARTE NOTIFICATION
  // =====================================================

  Widget _construireNotification(
      dynamic notification) {

    return Card(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            // =================================================
            // TITRE
            // =================================================

            Row(
              children: [

                Container(
                  padding:
                  const EdgeInsets.all(7),
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
                    size: 20,
                  ),
                ),

                const SizedBox(
                  width: 9,
                ),

                Expanded(
                  child: Text(
                    notification["titre"] ??
                        "Notification",
                    style:
                    const TextStyle(
                      fontSize: 15,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            // =================================================
            // MESSAGE + DATE
            // =================================================

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(10),
              decoration:
              BoxDecoration(
                color:
                Colors.grey.withValues(
                  alpha: 0.06,
                ),
                borderRadius:
                BorderRadius.circular(9),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  // MESSAGE
                  Text(
                    notification["message"] ??
                        "",
                    style:
                    const TextStyle(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(
                    height: 8,
                  ),

                  // TEMPS ÉCOULÉ
                  Text(
                    tempsEcoule(
                      notification[
                      "dateCreation"],
                    ),
                    style:
                    const TextStyle(
                      fontSize: 11,
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

          const Icon(
            Icons.notifications_none,
            color: Colors.blue,
            size: 70,
          ),

          const SizedBox(
            height: 15,
          ),

          const Text(
            "Aucune notification",
            style: TextStyle(
              fontSize: 19,
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
      body: _construireContenu(),
    );
  }

  // =====================================================
  // CONTENU
  // =====================================================

  Widget _construireContenu() {

    // =====================================================
    // CHARGEMENT
    // =====================================================

    if (chargement) {
      return const Center(
        child:
        CircularProgressIndicator(),
      );
    }

    // =====================================================
    // ERREUR
    // =====================================================

    if (erreur != null) {
      return Center(
        child: Padding(
          padding:
          const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [

              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 55,
              ),

              const SizedBox(
                height: 12,
              ),

              Text(
                erreur!,
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(
                height: 18,
              ),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    chargement = true;
                    erreur = null;
                  });

                  chargerNotifications();
                },
                child: const Text(
                  "Réessayer",
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

    if (notifications.isEmpty) {
      return _aucuneNotification();
    }

    // =====================================================
    // LISTES
    // =====================================================

    final recentes =
        notificationsRecentes;

    final precedentes =
        notificationsPrecedentes;

    return RefreshIndicator(
      onRefresh:
      chargerNotifications,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding:
        const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        children: [

          // =================================================
          // NOTIFICATIONS RÉCENTES
          // =================================================

          if (recentes.isNotEmpty)
            ...recentes.map(
                  (notification) =>
                  _construireNotification(
                    notification,
                  ),
            ),

          // =================================================
          // BOUTON PRÉCÉDENTES
          // =================================================
          //
          // Le bouton apparaît UNIQUEMENT si
          // precedentes.isNotEmpty
          // =================================================

          if (precedentes.isNotEmpty)
            Padding(
              padding:
              const EdgeInsets.only(
                top: 5,
                bottom: 10,
              ),
              child: InkWell(
                borderRadius:
                BorderRadius.circular(10),
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
                    BorderRadius.circular(10),
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
                  _construireNotification(
                    notification,
                  ),
            ),
        ],
      ),
    );
  }
}