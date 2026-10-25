/// Representa la posición de un jugador en la clasificación de un torneo.
class TournamentStanding {
  const TournamentStanding({
    required this.placing,
    required this.playerName,
    required this.deckName,
    this.country = '',
    this.record = '',
  });

  final int placing;
  final String playerName;
  final String deckName;
  final String country;
  final String record;

  factory TournamentStanding.fromJson(Map<String, dynamic> json) {
    final deckMap = json['deck'] as Map<String, dynamic>?;
    final recordMap = json['record'] as Map<String, dynamic>?;

    String formattedRecord = '';
    if (recordMap != null) {
      final w = recordMap['wins'] ?? 0;
      final l = recordMap['losses'] ?? 0;
      final t = recordMap['ties'] ?? 0;
      formattedRecord = '$w-$l-$t';
    }

    return TournamentStanding(
      placing: json['placing'] is int
          ? json['placing'] as int
          : (int.tryParse(json['placing']?.toString() ?? '') ?? 0),
      playerName: json['name']?.toString() ?? 'Jugador',
      deckName: deckMap?['name']?.toString() ?? 'Mazo competitivo',
      country: json['country']?.toString() ?? '',
      record: formattedRecord,
    );
  }
}

/// Representa un torneo competitivo de Pokémon TCG.
class TournamentModel {
  const TournamentModel({
    this.id,
    required this.name,
    required this.city,
    required this.date,
    required this.winningDeck,
    required this.players,
    this.standings = const [],
  });

  final String? id;
  final String name;
  final String city;
  final String date;
  final String winningDeck;
  final int players;
  final List<TournamentStanding> standings;

  factory TournamentModel.fromJson(
    Map<String, dynamic> json, {
    List<TournamentStanding> standings = const [],
  }) {
    final winningDeckFromStandings = standings.isNotEmpty
        ? standings.first.deckName
        : null;

    final rawFormat = json['format']?.toString() ?? 'STANDARD';
    final formatLabel = rawFormat.toUpperCase() == 'STANDARD'
        ? 'Formato Estándar'
        : rawFormat;

    return TournamentModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Torneo competitivo',
      city: json['city']?.toString() ?? 'Online · $formatLabel',
      date: _formatIsoDate(json['date']?.toString()),
      winningDeck:
          winningDeckFromStandings ??
          json['winningDeck']?.toString() ??
          'En curso / Por definir',
      players: json['players'] is int
          ? json['players'] as int
          : (int.tryParse(json['players']?.toString() ?? '') ?? 0),
      standings: standings,
    );
  }

  static String _formatIsoDate(String? raw) {
    if (raw == null || raw.isEmpty) return 'Reciente';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;

    const months = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre',
    ];
    return '${parsed.day} de ${months[parsed.month - 1]}';
  }
}

/// Datos de respaldo para pruebas o modo sin conexión.
const sampleTournaments = [
  TournamentModel(
    name: 'Victory Road Cup',
    city: 'Toronto',
    date: '18 de abril',
    winningDeck: 'Charizard ex',
    players: 128,
    standings: [
      TournamentStanding(
        placing: 1,
        playerName: 'Alex Morgan',
        deckName: 'Charizard ex',
        country: 'CA',
        record: '7-1-0',
      ),
      TournamentStanding(
        placing: 2,
        playerName: 'Lucas Silva',
        deckName: 'Gardevoir ex',
        country: 'BR',
        record: '6-2-0',
      ),
      TournamentStanding(
        placing: 3,
        playerName: 'Kenji Sato',
        deckName: 'Dragapult ex',
        country: 'JP',
        record: '6-2-0',
      ),
    ],
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
