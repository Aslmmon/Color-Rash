import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/game_provider.dart';
import '../../domain/game_state.dart';
import '../widgets/color_button.dart';
import 'color_rush_game.dart';

// Convert to a StatefulConsumerWidget
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  // Create the game instance here
  late final ColorRushGame _game;

  @override
  void initState() {
    super.initState();
    // Get the colors and notifier from Riverpod
    final colors = ref.read(colorProvider);
    final gameNotifier = ref.read(gameProvider.notifier);

    // Create the game instance and pass the notifier to it
    _game = ColorRushGame(
      status: gameNotifier.state.status,
      gameColors: colors,
      notifier: gameNotifier, // Pass the notifier
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final gameNotifier = ref.read(gameProvider.notifier);
    final colors = ref.read(colorProvider);

    // Tell the game instance what the current status is
    _game.status = gameState.status;

    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: _game),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Text(
                'Score: ${gameState.score}',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 64.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    colors
                        .map(
                          (color) => ColorButton(
                            color: color,
                            onTap: () => _game.attemptCatch(color),
                          ),
                        )
                        .toList(),
              ),
            ),
          ),

          if (gameState.status != GameStatus.playing)
            Container(
              color: Colors.black.withOpacity(0.5), // Dark overlay
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (gameState.status == GameStatus.gameOver)
                      Text(
                        'Game Over',
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(color: Colors.white),
                      ),
                    if (gameState.status == GameStatus.gameOver)
                      const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: gameNotifier.startGame,
                      child: Text(
                        gameState.status == GameStatus.initial
                            ? 'Start Game'
                            : 'Play Again',
                        style: const TextStyle(fontSize: 20),
                      ),
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
