import 'package:flutter/material.dart';
import 'package:pokemeta/models/deck_model.dart';
import 'package:pokemeta/presentation/screens/decks/deck_detail_screen.dart';
import 'package:pokemeta/presentation/screens/decks/deck_form_screen.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:provider/provider.dart';

/// Lista de mazos guardados. Los datos viven en DecksProvider.
class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  /// Abre el formulario. Sin [deck] crea un mazo; con [deck] edita sus datos.
  Future<void> _openForm(BuildContext context, {DeckModel? deck}) async {
    final decks = context.read<DecksProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await Navigator.of(context).push<DeckModel>(
      MaterialPageRoute<DeckModel>(
        builder: (context) => DeckFormScreen(deck: deck),
      ),
    );
    if (result == null) return;

    if (deck == null) {
      decks.add(result);
    } else {
      decks.replace(deck, result);
    }
    messenger.showSnackBar(
      SnackBar(content: Text(deck == null ? 'Mazo creado' : 'Mazo actualizado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final decks = context.watch<DecksProvider>().decks;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Mis mazos', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _openForm(context),
            icon: const Icon(Icons.add),
            label: const Text('Nuevo mazo'),
          ),
        ),
        const SizedBox(height: 8),
        for (final deck in decks)
          Card(
            child: ListTile(
              leading: const Icon(Icons.style_outlined, size: 40),
              title: Text(deck.name),
              subtitle: Text(
                '${deck.format} · ${deck.cardCount}/60 cartas · '
                '${deck.cards.length} tipos de carta',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') _openForm(context, deck: deck);
                  // INTEGRACIÓN: 'delete' aún no tiene acción.
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Editar datos')),
                  PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                ],
              ),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => DeckDetailScreen(deck: deck),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
