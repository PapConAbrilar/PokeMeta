import 'package:flutter/material.dart';
import 'package:pokemeta/models/card_model.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:provider/provider.dart';

/// Selector para agregar cartas al mazo en construcción.
///
/// INTEGRACIÓN: [cards] recibe hoy todo el catálogo de ejemplo. Cuando exista
/// la colección del usuario, pasarla aquí.
class CardPickerScreen extends StatefulWidget {
  const CardPickerScreen({super.key, this.cards = sampleCards});

  final List<CardModel> cards;

  @override
  State<CardPickerScreen> createState() => _CardPickerScreenState();
}

class _CardPickerScreenState extends State<CardPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final deck = context.watch<ActiveDeckProvider>();
    final results = widget.cards
        .where((card) => card.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Agregar cartas')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                labelText: 'Buscar cartas',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '${deck.totalCards} de ${ActiveDeckProvider.maxCards} cartas '
                'en "${deck.title}"',
              ),
            ),
          ),
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text('No hay cartas que coincidan.'))
                : ListView(
                    children: [
                      for (final card in results)
                        ListTile(
                          leading: const Icon(Icons.image_outlined),
                          title: Text(card.name),
                          subtitle: Text('${card.type} · ${card.expansion}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: deck.copiesOf(card) == 0
                                    ? null
                                    : () => deck.remove(card),
                                icon: const Icon(Icons.remove_circle_outline),
                                tooltip: 'Quitar una copia de ${card.name}',
                              ),
                              Text('${deck.copiesOf(card)}'),
                              IconButton(
                                onPressed: deck.canAdd(card)
                                    ? () => deck.add(card)
                                    : null,
                                icon: const Icon(Icons.add_circle_outline),
                                tooltip: 'Agregar una copia de ${card.name}',
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
