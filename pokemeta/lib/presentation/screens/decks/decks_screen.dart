import 'package:flutter/material.dart';
import 'package:pokemeta/models/deck_model.dart';
import 'package:pokemeta/presentation/screens/decks/deck_detail_screen.dart';
import 'package:pokemeta/presentation/screens/decks/deck_form_screen.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:provider/provider.dart';

/// Lista de mazos guardados sincronizados con Supabase (Requisito 5).
class DecksScreen extends StatelessWidget {
  const DecksScreen({super.key});

  /// Abre el formulario. Sin [deck] crea un mazo; con [deck] edita sus datos.
  Future<void> _openForm(BuildContext context, {DeckModel? deck}) async {
    final decksProvider = context.read<DecksProvider>();
    final messenger = ScaffoldMessenger.of(context);

    final result = await Navigator.of(context).push<DeckModel>(
      MaterialPageRoute<DeckModel>(
        builder: (context) => DeckFormScreen(deck: deck),
      ),
    );
    if (result == null) return;

    try {
      if (deck == null) {
        await decksProvider.add(result);
      } else {
        await decksProvider.replace(deck, result);
      }
      messenger.showSnackBar(
        SnackBar(
          content: Text(deck == null ? 'Mazo creado en la nube' : 'Mazo actualizado'),
        ),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Diálogo de confirmación para eliminar un mazo (DELETE en Supabase).
  Future<void> _confirmDelete(BuildContext context, DeckModel deck) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar mazo'),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${deck.name}"? '
          'Esta acción lo borrará de tu cuenta y no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await context.read<DecksProvider>().delete(deck);
        messenger.showSnackBar(
          const SnackBar(content: Text('Mazo eliminado con éxito')),
        );
      } catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final decksProvider = context.watch<DecksProvider>();
    final decks = decksProvider.decks;

    return RefreshIndicator(
      onRefresh: () => context.read<DecksProvider>().loadDecks(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Mis mazos',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ),
              FilledButton.icon(
                onPressed: () => _openForm(context),
                icon: const Icon(Icons.add),
                label: const Text('Nuevo mazo'),
              ),
            ],
          ),
          if (decksProvider.isLoading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ],
          const SizedBox(height: 16),
          if (decks.isEmpty && !decksProvider.isLoading)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.style_outlined, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Aún no tienes mazos guardados',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crea tu primer mazo o arma uno desde el catálogo de cartas.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => _openForm(context),
                      child: const Text('Crear mazo ahora'),
                    ),
                  ],
                ),
              ),
            )
          else
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
                      if (value == 'delete') _confirmDelete(context, deck);
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
      ),
    );
  }
}