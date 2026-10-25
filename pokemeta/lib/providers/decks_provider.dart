import 'package:flutter/foundation.dart';
import 'package:pokemeta/models/deck_model.dart';

/// Lista de mazos GUARDADOS del usuario.
///
/// INTEGRACIÓN: este es el punto único para conectar Supabase.
/// `_decks` se reemplaza por los mazos de la base, y `add` / `replace`
/// deben llamar a crear y actualizar. Falta `delete`.
class DecksProvider extends ChangeNotifier {
  final List<DeckModel> _decks = List.of(sampleDecks);

  List<DeckModel> get decks => List.unmodifiable(_decks);

  void add(DeckModel deck) {
    _decks.add(deck);
    notifyListeners();
  }

  /// Reemplaza [old] por [updated]. Si [old] ya no está en la lista
  /// (por ejemplo, se renombró mientras se editaba), agrega [updated].
  void replace(DeckModel old, DeckModel updated) {
    final index = _decks.indexOf(old);
    if (index == -1) {
      _decks.add(updated);
    } else {
      _decks[index] = updated;
    }
    notifyListeners();
  }
}
