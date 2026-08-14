class UserModel {
  final String id;
  final String email;
  final String role;
  final String nom;
  final String telephone;
  final String adresse;

  UserModel({
    required this.id,
    required this.email,
    required this.role,
    required this.nom,
    required this.telephone,
    required this.adresse,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString() ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      nom: json['nom'] ?? '',
      telephone: json['telephone'] ?? '',
      adresse: json['adresse'] ?? '',
    );
  }
}