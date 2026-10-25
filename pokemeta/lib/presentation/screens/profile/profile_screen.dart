import 'package:flutter/material.dart';
import 'package:pokemeta/presentation/screens/login/login_screen.dart';
import 'package:pokemeta/presentation/screens/profile/trainer_details_screen.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final decksProvider = context.watch<DecksProvider>();
    User? currentUser;
    try {
      currentUser = Supabase.instance.client.auth.currentUser;
    } catch (_) {
      currentUser = null;
    }

    final userEmail = currentUser?.email ?? 'entrenador@pokemeta.com';
    final savedDecksCount = decksProvider.decks.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const CircleAvatar(child: Icon(Icons.person_outline)),
          title: Text(
            'Perfil de entrenador',
            style: Theme.of(context).textTheme.labelLarge,
          ),
          subtitle: Text(
            '$userEmail\nUltra League · #1.284',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          isThreeLine: true,
          trailing: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Editar perfil',
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _ProfileStat(value: '$savedDecksCount', label: 'Mazos guardados'),
                const _ProfileStat(value: '24', label: 'Victorias'),
                const _ProfileStat(value: '68%', label: 'Porcentaje'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Cuenta', style: Theme.of(context).textTheme.titleLarge),
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: const Text('Datos del entrenador'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => const TrainerDetailsScreen(),
              ),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('Cerrar sesión'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () async {
            // Requisito 1: Cierre de sesión en Supabase y limpieza de estado global
            try {
              await Supabase.instance.client.auth.signOut();
            } catch (_) {}

            if (context.mounted) {
              context.read<ActiveDeckProvider>().discard();
              context.read<DecksProvider>().clear();

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (context) => const LoginScreen(),
                ),
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }
}

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleLarge),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}