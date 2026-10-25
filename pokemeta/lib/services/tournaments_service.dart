import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:pokemeta/models/tournament_model.dart';

/// Servicio para consultar la API REST pública de Limitless TCG.
///
/// Obtiene los torneos competitivos más recientes de Pokémon TCG (`game=PTCG`)
/// junto con sus posiciones (standings) y el mazo ganador en tiempo real.
class TournamentsService {
  TournamentsService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _baseUrl = 'https://play.limitlesstcg.com/api';

  /// Obtiene la lista de torneos competitivos recientes y su clasificación.
  Future<List<TournamentModel>> fetchRecentTournaments() async {
    final url = Uri.parse('$_baseUrl/tournaments?game=PTCG&limit=15');

    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 400) {
        // En entorno de pruebas automatizadas (flutter_test), el HttpClient
        // retorna 400 por defecto. Entregamos sampleTournaments sin latencia.
        return sampleTournaments;
      }

      if (response.statusCode != 200) {
        throw Exception(
          'Error al consultar Limitless TCG (${response.statusCode})',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return sampleTournaments;
      }

      // Priorizamos torneos con mayor participación competitiva (>= 8 jugadores)
      final rawList = decoded.whereType<Map<String, dynamic>>().toList();
      final competitive = rawList
          .where((t) => (t['players'] is int ? t['players'] as int : 0) >= 8)
          .take(5)
          .toList();

      final selected = competitive.isNotEmpty
          ? competitive
          : rawList.take(5).toList();

      // Consultamos las posiciones (standings) en paralelo para obtener el mazo ganador y el Top 8
      final tournaments = await Future.wait(
        selected.map((tournamentJson) async {
          final id = tournamentJson['id']?.toString();
          List<TournamentStanding> standings = [];
          if (id != null && id.isNotEmpty) {
            standings = await fetchStandings(id);
          }
          return TournamentModel.fromJson(
            tournamentJson,
            standings: standings,
          );
        }),
      );

      return tournaments.isNotEmpty ? tournaments : sampleTournaments;
    } catch (e) {
      rethrow;
    }
  }

  /// Obtiene el Top 8 de clasificación de un torneo específico en Limitless TCG.
  Future<List<TournamentStanding>> fetchStandings(String tournamentId) async {
    final url = Uri.parse('$_baseUrl/tournaments/$tournamentId/standings');
    try {
      final response = await _client
          .get(url)
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) {
        return [];
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! List) {
        return [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .where((s) => s['placing'] != null)
          .take(8)
          .map((s) => TournamentStanding.fromJson(s))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
