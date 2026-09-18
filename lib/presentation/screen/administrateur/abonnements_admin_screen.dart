import 'package:flutter/material.dart';
import '../../../metier/services/api_service.dart';
import '../../../metier/services/storage_service.dart';
import '../../../metier/models/user_model.dart';

class AbonnementsAdminScreen extends StatefulWidget {
  final UserModel user;

  const AbonnementsAdminScreen({super.key, required this.user});

  @override
  State<AbonnementsAdminScreen> createState() => _AbonnementsAdminScreenState();
}

class _AbonnementsAdminScreenState extends State<AbonnementsAdminScreen> {
  List<dynamic> _abonnements = [];
  Map<String, dynamic>? _statistiques;
  bool _isLoading = true;
  String? _filtreStatut; // null = tous

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final token = await StorageService.getToken();
      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final abonnements = await ApiService.getAllAbonnements(
        token,
        statut: _filtreStatut,
      );
      final stats = await ApiService.getAbonnementsStatistiques(token);

      setState(() {
        _abonnements = abonnements;
        _statistiques = stats;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Erreur récupération abonnements admin : $e");
      setState(() {
        _abonnements = [];
        _isLoading = false;
      });
    }
  }

  Color _colorForStatut(String statut) {
    switch (statut) {
      case "essai":
        return Colors.orange;
      case "actif":
        return Colors.green;
      case "expire":
        return Colors.red;
      case "impaye":
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
    }
  }

  String _labelStatut(String statut) {
    switch (statut) {
      case "essai":
        return "Essai";
      case "actif":
        return "Actif";
      case "expire":
        return "Expiré";
      case "impaye":
        return "Impayé";
      default:
        return statut;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Abonnements des automobilistes"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchData,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_statistiques != null) _buildStatistiquesCard(),
            const SizedBox(height: 20),
            _buildFiltres(),
            const SizedBox(height: 10),
            if (_abonnements.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text("Aucun abonnement trouvé")),
              )
            else
              ..._abonnements.map(_buildAbonnementCard),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistiquesCard() {
    final parStatut = _statistiques!['parStatut'] ?? {};

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Vue d'ensemble",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statChip("Essai", parStatut['essai'] ?? 0, Colors.orange),
                _statChip("Actif", parStatut['actif'] ?? 0, Colors.green),
                _statChip("Expiré", parStatut['expire'] ?? 0, Colors.red),
                _statChip("Impayé", parStatut['impaye'] ?? 0, Colors.deepOrange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildFiltres() {
    final options = {
      null: "Tous",
      "essai": "Essai",
      "actif": "Actif",
      "expire": "Expiré",
      "impaye": "Impayé",
    };

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: options.entries.map((entry) {
          final isSelected = _filtreStatut == entry.key;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) {
                setState(() => _filtreStatut = entry.key);
                _fetchData();
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAbonnementCard(dynamic abonnement) {
    final automobiliste = abonnement['automobiliste'] ?? {};
    final plan = abonnement['plan'];
    final statut = abonnement['statut'] ?? '';
    final color = _colorForStatut(statut);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(Icons.person, color: color),
        ),
        title: Text(
          automobiliste['nom'] ?? 'Utilisateur inconnu',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${automobiliste['email'] ?? ''}\n"
              "Plan : ${plan != null ? (plan['nomAffiche'] ?? plan['nom']) : 'Aucun'}",
        ),
        isThreeLine: true,
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            _labelStatut(statut),
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}