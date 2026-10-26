import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/models/deck_model.dart';

/// Representa la posición de un jugador en la clasificación de un torneo,
/// incluyendo su lista de cartas (`deckCards`) si está disponible en Limitless TCG.
class TournamentStanding {
  const TournamentStanding({
    required this.placing,
    required this.playerName,
    required this.deckName,
    this.country = '',
    this.record = '',
    this.deckCards = const [],
  });

  final int placing;
  final String playerName;
  final String deckName;
  final String country;
  final String record;
  final List<DeckCardEntry> deckCards;

  bool get hasDecklist => deckCards.isNotEmpty;

  /// Convierte el mazo jugado por este competidor en un [DeckModel]
  /// listo para visualizarse o guardarse en la cuenta del usuario.
  DeckModel toDeckModel(String tournamentName) {
    final descriptionText =
        'Mazo #$placing de $playerName en $tournamentName'
        '${record.isNotEmpty ? ' (Récord $record)' : ''}.';

    return DeckModel(
      name: deckName,
      format: 'Estándar',
      description: descriptionText.length > 200
          ? descriptionText.substring(0, 200)
          : descriptionText,
      cards: deckCards,
    );
  }

  factory TournamentStanding.fromJson(Map<String, dynamic> json) {
    final deckMap = json['deck'] as Map<String, dynamic>?;
    final recordMap = json['record'] as Map<String, dynamic>?;
    final decklistMap = json['decklist'] as Map<String, dynamic>?;

    String formattedRecord = '';
    if (recordMap != null) {
      final w = recordMap['wins'] ?? 0;
      final l = recordMap['losses'] ?? 0;
      final t = recordMap['ties'] ?? 0;
      formattedRecord = '$w-$l-$t';
    }

    final parsedCards = _parseLimitlessDecklist(decklistMap);

    return TournamentStanding(
      placing: json['placing'] is int
          ? json['placing'] as int
          : (int.tryParse(json['placing']?.toString() ?? '') ?? 0),
      playerName: json['name']?.toString() ?? 'Jugador',
      deckName: deckMap?['name']?.toString() ?? 'Mazo competitivo',
      country: json['country']?.toString() ?? '',
      record: formattedRecord,
      deckCards: parsedCards,
    );
  }

  /// Convierte el objeto `decklist` (`pokemon`, `trainer`, `energy`) de Limitless TCG
  /// en entradas [DeckCardEntry] con sus imágenes oficiales en alta resolución.
  static List<DeckCardEntry> _parseLimitlessDecklist(
    Map<String, dynamic>? decklist,
  ) {
    if (decklist == null) return const [];

    final entries = <DeckCardEntry>[];
    final categories = <String, String>{
      'pokemon': 'Pokémon',
      'trainer': 'Entrenador',
      'energy': 'Energía',
    };

    categories.forEach((key, typeLabel) {
      final rawGroup = decklist[key];
      if (rawGroup is List) {
        for (final item in rawGroup.whereType<Map<String, dynamic>>()) {
          final count = item['count'] is int
              ? item['count'] as int
              : (int.tryParse(item['count']?.toString() ?? '') ?? 1);
          final name = item['name']?.toString() ?? 'Carta';
          final setCode = (item['set']?.toString() ?? 'SVI').toUpperCase();
          final rawNumber = item['number']?.toString() ?? '1';
          final paddedNumber = rawNumber.padLeft(3, '0');

          final imageUrl =
              'https://limitlesstcg.nyc3.cdn.digitaloceanspaces.com/tpci/'
              '$setCode/${setCode}_${paddedNumber}_R_EN_LG.png';

          entries.add(
            DeckCardEntry(
              count: count,
              card: CardModel(
                name: name,
                expansion: setCode,
                rarity: 'Competitiva',
                cardNumber: '$setCode-$paddedNumber',
                hp: key == 'pokemon' ? 120 : 0,
                type: typeLabel,
                ability: 'Carta de torneo oficial',
                attack: 'Jugada competitiva',
                attackDamage: '—',
                attackDescription:
                    'Carta incluida en el mazo competitivo de Limitless TCG '
                    '($setCode #$rawNumber).',
                retreatCost: 1,
                weakness: '—',
                resistance: '—',
                regulationMark: 'H',
                imageUrl: imageUrl,
              ),
            ),
          );
        }
      }
    });

    return entries;
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

  /// Devuelve el mazo del ganador (#1) o del primer jugador que tenga decklist.
  DeckModel? get winnerDeckModel {
    for (final standing in standings) {
      if (standing.hasDecklist) {
        return standing.toDeckModel(name);
      }
    }
    return null;
  }

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
final sampleTournaments = [
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
        deckCards: sampleDecks.first.cards,
      ),
      TournamentStanding(
        placing: 2,
        playerName: 'Lucas Silva',
        deckName: 'Gardevoir ex',
        country: 'BR',
        record: '6-2-0',
        deckCards: sampleDecks[1].cards,
      ),
      TournamentStanding(
        placing: 3,
        playerName: 'Kenji Sato',
        deckName: 'Greninja ex',
        country: 'JP',
        record: '6-2-0',
        deckCards: sampleDecks[2].cards,
      ),
    ],
  ),
  const TournamentModel(
    name: 'Neon City League',
    city: 'Nueva York',
    date: '12 de abril',
    winningDeck: 'Lost Zone Box',
    players: 96,
  ),
  const TournamentModel(
    name: 'Regional Qualifier',
    city: 'Seattle',
    date: '5 de abril',
    winningDeck: 'Gardevoir ex',
    players: 214,
  ),
];
