import 'package:flutter/material.dart';
import 'package:pokemeta/models/deck_model.dart';
import 'package:pokemeta/presentation/screens/cards/card_detail_screen.dart';
import 'package:pokemeta/presentation/screens/decks/active_deck_screen.dart';
import 'package:pokemeta/presentation/screens/decks/deck_form_screen.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:pokemeta/widgets/card_image.dart';
import 'package:pokemeta/widgets/stat_badge_widget.dart';
import 'package:provider/provider.dart';

/// Detalle de un mazo guardado. Guarda el mazo mostrado en `_deck`
/// porque puede cambiar al editarlo desde esta pantalla.
class DeckDetailScreen extends StatefulWidget {
  const DeckDetailScreen({super.key, required this.deck});

  final DeckModel deck;

  @override
  State<DeckDetailScreen> createState() => _DeckDetailScreenState();
}

class _DeckDetailScreenState extends State<DeckDetailScreen> {
  late DeckModel _deck;

  @override
  void initState() {
    super.initState();
    _deck = widget.deck;
  }

  /// Edita nombre, formato y descripción con el formulario.
  Future<void> _editData() async {
    final decks = context.read<DecksProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await Navigator.of(context).push<DeckModel>(
      MaterialPageRoute<DeckModel>(
        builder: (context) => DeckFormScreen(deck: _deck),
      ),
    );
    if (result == null || !mounted) return;

    decks.replace(_deck, result);
    setState(() => _deck = result);
    messenger.showSnackBar(const SnackBar(content: Text('Mazo actualizado')));
  }

  /// Carga este mazo como borrador y abre el editor de cartas.
  Future<void> _editCards() async {
    final active = context.read<ActiveDeckProvider>();
    final navigator = Navigator.of(context);

    // Si hay otro borrador sin guardar, se pide confirmación.
    if (active.hasDraft && active.source != _deck) {
      final proceed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reemplazar borrador'),
          content: const Text(
            'Tienes un mazo en construcción sin guardar. '
            'Si continúas, se descartará.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Continuar'),
            ),
          ],
        ),
      );
      if (proceed != true) return;
    }

    if (active.source != _deck) active.startEditing(_deck);

    final saved = await navigator.push<DeckModel>(
      MaterialPageRoute<DeckModel>(
        builder: (context) => const ActiveDeckScreen(),
      ),
    );
    if (saved == null || !mounted) return;
    setState(() => _deck = saved);
  }

  @override
  Widget build(BuildContext context) {
    final deck = _deck;
    final pokemonCount = deck.cards
        .where((entry) => entry.card.type != 'Entrenador')
        .fold(0, (total, entry) => total + entry.count);
    final typeCount = deck.cards.map((entry) => entry.card.type).toSet().length;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.name),
        actions: [
          IconButton(
            onPressed: _editData,
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar datos del mazo',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(deck.format, style: Theme.of(context).textTheme.labelLarge),
          if (deck.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(deck.description),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: _editData,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar datos'),
              ),
              FilledButton.tonalIcon(
                onPressed: _editCards,
                icon: const Icon(Icons.style_outlined),
                label: const Text('Editar cartas'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Contenido del mazo',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  StatBadgeWidget(value: '${deck.cardCount}', label: 'Cartas'),
                  StatBadgeWidget(value: '$pokemonCount', label: 'Pokémon'),
                  StatBadgeWidget(value: '$typeCount', label: 'Tipos'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Cartas', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          if (deck.cards.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.inbox_outlined),
                title: Text('Este mazo aún no tiene cartas'),
                subtitle: Text('Usa "Editar cartas" para agregarlas.'),
              ),
            )
          else
            for (final entry in deck.cards)
              Card(
                child: ListTile(
                  leading: SizedBox(
                    width: 40,
                    height: 56,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: CardImage(card: entry.card, iconSize: 24),
                    ),
                  ),
                  title: Text(entry.card.name),
                  subtitle: Text(
                    '${entry.card.type} · ${entry.card.expansion}',
                  ),
                  trailing: Text('×${entry.count}'),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) =>
                            CardDetailScreen(card: entry.card),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }
}
