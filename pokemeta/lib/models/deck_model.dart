import 'package:pokemeta/models/card_model.dart';

class DeckCardEntry {
  const DeckCardEntry({required this.card, required this.count});

  final CardModel card;
  final int count;

  factory DeckCardEntry.fromJson(Map<String, dynamic> json) {
    return DeckCardEntry(
      card: CardModel.fromJson(json['card'] as Map<String, dynamic>),
      count: json['count'] is int
          ? json['count'] as int
          : (int.tryParse(json['count']?.toString() ?? '') ?? 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'card': card.toJson(),
      'count': count,
    };
  }
}

class DeckModel {
  const DeckModel({
    this.id,
    required this.name,
    required this.format,
    required this.cards,
    this.description = '',
  });

  final String? id;
  final String name;
  final String format;
  final List<DeckCardEntry> cards;
  final String description;

  int get cardCount => cards.fold(0, (total, entry) => total + entry.count);

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    final rawCards = json['cards'];
    List<DeckCardEntry> parsedCards = [];
    if (rawCards is List) {
      parsedCards = rawCards
          .whereType<Map<String, dynamic>>()
          .map((c) => DeckCardEntry.fromJson(c))
          .toList();
    }

    return DeckModel(
      id: json['id']?.toString(),
      name: json['name']?.toString() ?? 'Mazo sin nombre',
      format: json['format']?.toString() ?? 'Estándar',
      description: json['description']?.toString() ?? '',
      cards: parsedCards,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'format': format,
      'description': description,
      'cards': cards.map((c) => c.toJson()).toList(),
    };
  }
}

final sampleDecks = [
  DeckModel(
    name: 'Infernal Reign',
    format: 'Estándar',
    description: 'Mazo de Charizard ex que escala el daño con los Premios.',
    cards: [
      DeckCardEntry(card: sampleCards[0], count: 3),
      DeckCardEntry(card: sampleCards[3], count: 4),
      DeckCardEntry(card: sampleCards[1], count: 2),
    ],
  ),
  DeckModel(
    name: 'Moonlight Control',
    format: 'Estándar',
    description: 'Control con Mew ex para copiar los ataques del rival.',
    cards: [
      DeckCardEntry(card: sampleCards[2], count: 2),
      DeckCardEntry(card: sampleCards[3], count: 4),
      DeckCardEntry(card: sampleCards[1], count: 2),
    ],
  ),
  DeckModel(
    name: 'Thunder Circuit',
    format: 'Expandido',
    description: 'Mazo agresivo de Expandido centrado en Greninja ex.',
    cards: [
      DeckCardEntry(card: sampleCards[1], count: 4),
      DeckCardEntry(card: sampleCards[2], count: 2),
      DeckCardEntry(card: sampleCards[0], count: 2),
    ],
  ),
];
