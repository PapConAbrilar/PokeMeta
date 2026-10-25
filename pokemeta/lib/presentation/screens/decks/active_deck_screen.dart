import 'package:flutter/material.dart';
import 'package:pokemeta/models/deck_model.dart';
import 'package:pokemeta/presentation/screens/decks/card_picker_screen.dart';
import 'package:pokemeta/presentation/screens/decks/deck_form_screen.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:provider/provider.dart';

/// Editor del mazo en construcción: ver cartas, ajustar copias,
/// agregar más y guardar.
class ActiveDeckScreen extends StatelessWidget {
  const ActiveDeckScreen({super.key});

  Future<void> _save(BuildContext context) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final active = context.read<ActiveDeckProvider>();
    final decks = context.read<DecksProvider>();
    final source = active.source;

    final DeckModel saved;
    if (source != null) {
      // Mazo existente: se conservan sus datos y se actualizan las cartas.
      saved = DeckModel(
        name: source.name,
        format: source.format,
        description: source.description,
        cards: active.entries,
      );
      decks.replace(source, saved);
    } else {
      // Mazo nuevo: primero se piden nombre, formato y descripción.
      final info = await navigator.push<DeckModel>(
        MaterialPageRoute<DeckModel>(
          builder: (context) => const DeckFormScreen(),
        ),
      );
      if (info == null) return;
      saved = DeckModel(
        name: info.name,
        format: info.format,
        description: info.description,
        cards: active.entries,
      );
      decks.add(saved);
    }

    active.discard();
    messenger.showSnackBar(const SnackBar(content: Text('Mazo guardado')));
    navigator.pop(saved);
  }

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<ActiveDeckProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.title),
        actions: [
          IconButton(
            onPressed: deck.hasDraft ? deck.discard : null,
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Descartar cambios',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            '${deck.totalCards} de ${ActiveDeckProvider.maxCards} cartas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (deck.source != null) ...[
            const SizedBox(height: 4),
            const Text(
              'Editando un mazo guardado. Los cambios se aplican al pulsar '
              '"Guardar cambios".',
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => const CardPickerScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Agregar cartas'),
              ),
              FilledButton.icon(
                onPressed: deck.isEmpty ? null : () => _save(context),
                icon: const Icon(Icons.check),
                label: Text(
                  deck.source == null ? 'Guardar mazo' : 'Guardar cambios',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (deck.isEmpty)
            const Card(
              child: ListTile(
                leading: Icon(Icons.inbox_outlined),
                title: Text('Aún no hay cartas'),
                subtitle: Text(
                  'Usa "Agregar cartas" o ábrelas desde el catálogo.',
                ),
              ),
            )
          else
            for (final entry in deck.entries)
              Card(
                child: ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: Text(entry.card.name),
                  subtitle: Text('${entry.card.type} · ${entry.card.expansion}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => deck.remove(entry.card),
                        icon: const Icon(Icons.remove_circle_outline),
                        tooltip: 'Quitar una copia',
                      ),
                      Text('${entry.count}'),
                      IconButton(
                        onPressed: deck.canAdd(entry.card)
                            ? () => deck.add(entry.card)
                            : null,
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Agregar una copia',
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}
