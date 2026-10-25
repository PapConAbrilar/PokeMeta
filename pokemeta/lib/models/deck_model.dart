import 'package:pokemeta/models/card_model.dart';

class DeckCardEntry {
  const DeckCardEntry({required this.card, required this.count});

  final CardModel card;
  final int count;
}

class DeckModel {
  const DeckModel({
    required this.name,
    required this.format,
    required this.cards,
    this.description = '',
  });

  final String name;
  final String format;
  final List<DeckCardEntry> cards;
  final String description;

  int get cardCount => cards.fold(0, (total, entry) => total + entry.count);
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
