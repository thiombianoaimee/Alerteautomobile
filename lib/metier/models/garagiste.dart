class Garagiste {
  final String? id;
  final String username;
  final String email;
  final String password;
  final String numtel;
  final String adresse;
  final bool disponibilite;

  Garagiste({
    this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.numtel,
    required this.adresse,
    this.disponibilite = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'numtel': numtel,
      'adresse': adresse,
      'disponibilite': disponibilite,
    };
  }

  factory Garagiste.fromJson(Map<String, dynamic> json) {
    return Garagiste(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      numtel: json['numtel'],
      adresse: json['adresse'],
      disponibilite: json['disponibilite'] ?? true,
    );
  }
}