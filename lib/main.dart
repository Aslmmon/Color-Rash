import 'package:color_rash/presentation/game/game_screen.dart';
import 'package:color_rash/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Color Rush',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // <-- Use your custom theme here
      home: const GameScreen(), // <-- Updated this line
    );
  }
}

