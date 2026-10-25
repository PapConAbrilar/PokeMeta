/// Representa un torneo competitivo de Pokémon TCG.
class TournamentModel {
  const TournamentModel({
    required this.name,
    required this.city,
    required this.date,
    required this.winningDeck,
    required this.players,
  });

  final String name;
  final String city;
  final String date;
  final String winningDeck;
  final int players;

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      name: json['name']?.toString() ?? 'Torneo competitivo',
      city: json['city']?.toString() ?? 'Internacional',
      date: json['date']?.toString() ?? 'Reciente',
      winningDeck: json['winningDeck']?.toString() ?? 'Desconocido',
      players: json['players'] is int
          ? json['players']
          : (int.tryParse(json['players']?.toString() ?? '') ?? 0),
    );
  }
}

/// Datos de ejemplo. Más adelante se reemplazan por los de la API.
const sampleTournaments = [
  TournamentModel(
    name: 'Victory Road Cup',
    city: 'Toronto',
    date: '18 de abril',
    winningDeck: 'Charizard ex',
    players: 128,
  ),
  TournamentModel(
    name: 'Neon City League',
    city: 'Nueva York',
    date: '12 de abril',
    winningDeck: 'Lost Zone Box',
    players: 96,
  ),
  TournamentModel(
    name: 'Regional Qualifier',
    city: 'Seattle',
    date: '5 de abril',
    winningDeck: 'Gardevoir ex',
    players: 214,
  ),
];
