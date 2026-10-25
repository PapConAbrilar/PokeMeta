import 'package:flutter/foundation.dart';
import 'package:pokemeta/models/deck_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Lista de mazos GUARDADOS del usuario sincronizada con Supabase (CRUD con RLS).
///
/// Cumple con el Requisito 5 de la asignatura: operaciones asíncronas
/// de creación, lectura, actualización y borrado vinculadas a la sesión activa.
class DecksProvider extends ChangeNotifier {
  List<DeckModel> _decks = List.of(sampleDecks);
  bool _isLoading = false;
  String? _errorMessage;

  List<DeckModel> get decks => List.unmodifiable(_decks);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SupabaseClient? get _supabase {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  bool get _isAuthenticated {
    try {
      return _supabase?.auth.currentUser != null;
    } catch (_) {
      return false;
    }
  }

  /// Carga los mazos desde la tabla `decks` de Supabase respetando RLS.
  Future<void> loadDecks() async {
    if (!_isAuthenticated) {
      // Si no hay sesión iniciada, muestra los mazos de ejemplo
      _decks = List.of(sampleDecks);
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase!
          .from('decks')
          .select()
          .order('created_at', ascending: false);

      _decks = (response as List)
          .whereType<Map<String, dynamic>>()
          .map((data) => DeckModel.fromJson(data))
          .toList();
    } catch (e) {
      _errorMessage = 'No se pudieron cargar los mazos: $e';
      // Mantiene los mazos de respaldo en caso de error
      if (_decks.isEmpty) {
        _decks = List.of(sampleDecks);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Crea un nuevo mazo (INSERT con RLS).
  Future<void> add(DeckModel deck) async {
    if (!_isAuthenticated) {
      _decks.add(deck);
      notifyListeners();
      return;
    }

    try {
      final response = await _supabase!
          .from('decks')
          .insert({
            'name': deck.name,
            'format': deck.format,
            'description': deck.description,
            'cards': deck.cards.map((c) => c.toJson()).toList(),
          })
          .select()
          .single();

      final createdDeck = DeckModel.fromJson(response);
      _decks.insert(0, createdDeck);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al guardar el mazo: $e';
      // Agrega localmente de respaldo
      _decks.add(deck);
      notifyListeners();
      rethrow;
    }
  }

  /// Actualiza un mazo existente (UPDATE con RLS).
  Future<void> replace(DeckModel oldDeck, DeckModel updatedDeck) async {
    final index = _decks.indexOf(oldDeck);

    if (!_isAuthenticated || oldDeck.id == null) {
      if (index == -1) {
        _decks.add(updatedDeck);
      } else {
        _decks[index] = updatedDeck;
      }
      notifyListeners();
      return;
    }

    try {
      final response = await _supabase!
          .from('decks')
          .update({
            'name': updatedDeck.name,
            'format': updatedDeck.format,
            'description': updatedDeck.description,
            'cards': updatedDeck.cards.map((c) => c.toJson()).toList(),
          })
          .eq('id', oldDeck.id!)
          .select()
          .single();

      final savedDeck = DeckModel.fromJson(response);
      if (index == -1) {
        _decks.add(savedDeck);
      } else {
        _decks[index] = savedDeck;
      }
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al actualizar el mazo: $e';
      if (index != -1) {
        _decks[index] = updatedDeck;
      }
      notifyListeners();
      rethrow;
    }
  }

  /// Elimina un mazo (DELETE con RLS).
  Future<void> delete(DeckModel deck) async {
    final index = _decks.indexOf(deck);
    if (index != -1) {
      _decks.removeAt(index);
      notifyListeners();
    }

    if (_isAuthenticated && deck.id != null) {
      try {
        await _supabase!.from('decks').delete().eq('id', deck.id!);
      } catch (e) {
        _errorMessage = 'Error al eliminar el mazo: $e';
        // Si falló en el servidor, revertimos la eliminación local
        if (index != -1) {
          _decks.insert(index, deck);
          notifyListeners();
        }
        rethrow;
      }
    }
  }

  /// Limpia los mazos de la memoria al cerrar sesión.
  void clear() {
    _decks = List.of(sampleDecks);
    notifyListeners();
  }
}
