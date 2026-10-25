import 'package:flutter/foundation.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/models/deck_model.dart';

/// Borrador del mazo que el usuario está armando o editando.
///
/// - Si [source] es null, es un mazo nuevo que aún no se guardó.
/// - Si [source] tiene un mazo, se están editando las cartas de ese mazo.
///
/// Los cambios solo se aplican a un mazo guardado cuando se pulsa
/// "Guardar" (eso ocurre en ActiveDeckScreen, usando DecksProvider).
class ActiveDeckProvider extends ChangeNotifier {
  static const int maxCards = 60;

  /// Regla simplificada: máximo 4 copias por carta (en el juego real las
  /// energías básicas no tienen este límite).
  static const int maxCopies = 4;

  DeckModel? _source;

  // Clave: número de carta (único). Valor: la carta y cuántas copias hay.
  final Map<String, DeckCardEntry> _entries = {};

  DeckModel? get source => _source;

  String get title => _source?.name ?? 'Mazo nuevo';

  /// Copia de solo lectura: desde afuera no se puede modificar la lista.
  List<DeckCardEntry> get entries => List.unmodifiable(_entries.values);

  bool get isEmpty => _entries.isEmpty;

  /// Hay algo en construcción (un mazo cargado o cartas sueltas).
  bool get hasDraft => _source != null || _entries.isNotEmpty;

  int get totalCards =>
      _entries.values.fold(0, (total, entry) => total + entry.count);

  int copiesOf(CardModel card) => _entries[card.cardNumber]?.count ?? 0;

  bool canAdd(CardModel card) =>
      totalCards < maxCards && copiesOf(card) < maxCopies;

  /// Carga un mazo guardado para editar sus cartas.
  void startEditing(DeckModel deck) {
    _source = deck;
    _entries
      ..clear()
      ..addEntries(
        deck.cards.map((entry) => MapEntry(entry.card.cardNumber, entry)),
      );
    notifyListeners();
  }

  void add(CardModel card) {
    if (!canAdd(card)) return;
    _entries[card.cardNumber] = DeckCardEntry(
      card: card,
      count: copiesOf(card) + 1,
    );
    notifyListeners();
  }

  void remove(CardModel card) {
    final copies = copiesOf(card);
    if (copies == 0) return;
    if (copies == 1) {
      _entries.remove(card.cardNumber);
    } else {
      _entries[card.cardNumber] = DeckCardEntry(
        card: card,
        count: copies - 1,
      );
    }
    notifyListeners();
  }

  /// Descarta el borrador completo. Un mazo guardado no se toca.
  void discard() {
    if (!hasDraft) return;
    _source = null;
    _entries.clear();
    notifyListeners();
  }
}
