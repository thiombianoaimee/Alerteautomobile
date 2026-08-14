class Automobiliste {
  final String? id;
  final String username;
  final String email;
  final String password;
  final String numtel;
  final String adresse;

  Automobiliste({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.numtel,
    required this.adresse,
  });

  // Convertit un objet Automobiliste en JSON (pour l'envoyer au backend)
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'numtel': numtel,
      'adresse': adresse,
    };
  }

  // Convertit du JSON reçu du backend en objet Automobiliste
  factory Automobiliste.fromJson(Map<String, dynamic> json) {
    return Automobiliste(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      numtel: json['numtel'],
      adresse: json['adresse'],
    );
  }
}