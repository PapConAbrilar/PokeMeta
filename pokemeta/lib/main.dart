import 'package:flutter/material.dart';
import 'package:pokemeta/presentation/screens/login/login_screen.dart';
import 'package:pokemeta/presentation/screens/main_navigation_screen.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Requisito 1: Inicialización del cliente oficial de Supabase
  await Supabase.initialize(
    url: 'https://uzsgzxfokdzedmdoylsc.supabase.co',
    publishableKey: 'sb_publishable_AdoEKt2UMxffSWpHmZy4Ig_-tv7ivCq',
  );

  runApp(const PokeMetaApp());
}

class PokeMetaApp extends StatelessWidget {
  const PokeMetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    bool hasSession = false;
    try {
      hasSession = Supabase.instance.client.auth.currentSession != null;
    } catch (_) {
      hasSession = false;
    }

    // Los providers van POR ENCIMA de MaterialApp para que todas las
    // pantallas (incluidas las que se abren con Navigator) los vean.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final provider = DecksProvider();
            if (hasSession) {
              provider.loadDecks();
            }
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => ActiveDeckProvider()),
      ],
      child: MaterialApp(
        title: 'PokeMeta',
        theme: ThemeData(),
        home: hasSession ? const MainNavigationScreen() : const LoginScreen(),
      ),
    );
  }
}
