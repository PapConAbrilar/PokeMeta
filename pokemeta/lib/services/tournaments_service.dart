import 'dart:async';
import 'package:pokemeta/models/tournament_model.dart';

/// Servicio para consultar la información de torneos competitivos de Pokémon TCG.
///
/// Implementa consumo asíncrono con `Future` para alimentar los `FutureBuilder`
/// de la aplicación (Requisito 2).
class TournamentsService {
  /// Obtiene la lista de torneos competitivos recientes.
  Future<List<TournamentModel>> fetchRecentTournaments() async {
    // Simula latencia de red asíncrona para demostrar el ciclo de vida de FutureBuilder
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // Retorna la lista de torneos
    return sampleTournaments;
  }
}

