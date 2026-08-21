class ApiConfig {
  // URL de base du backend
  static const String baseUrl = "http://10.0.2.2:5000/api";

  // Authentification
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";

  // Véhicules
  static const String vehicles = "$baseUrl/vehicles";

  // Garagistes
  static String garages = "$baseUrl/users/garagistes";

  // Créneaux
  static const String creneaux = "$baseUrl/creneaux";

  // Rendez-vous
  static const String rdv = "$baseUrl/appointments";

  // Notifications
  static const String notifications = "$baseUrl/notifications";
}