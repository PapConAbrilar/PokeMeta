import 'package:flutter/material.dart';
import 'package:pokemeta/presentation/screens/login/login_screen.dart';
import 'package:pokemeta/providers/active_deck_provider.dart';
import 'package:pokemeta/providers/decks_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // Los providers van POR ENCIMA de MaterialApp para que todas las
    // pantallas (incluidas las que se abren con Navigator) los vean.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DecksProvider()),
        ChangeNotifierProvider(create: (_) => ActiveDeckProvider()),
      ],
      child: const PokeMetaApp(),
    ),
  );
}

class PokeMetaApp extends StatelessWidget {
  const PokeMetaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PokeMeta',
      theme: ThemeData(),
      home: const LoginScreen(),
    );
  }
}
