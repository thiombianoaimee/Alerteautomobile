class ApiConfig {
  // URL de base du backend
  static const String baseUrl = "http://10.17.21.89:5000/api";
  // Authentification
  static const String login = "$baseUrl/auth/login";
  static const String register = "$baseUrl/auth/register";
  static const String forgotPassword = "$baseUrl/auth/forgot-password";
  static const String resetPassword = "$baseUrl/auth/reset-password";

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

  // Configuration alertes
  static const String config = "$baseUrl/alert-settings";
}
