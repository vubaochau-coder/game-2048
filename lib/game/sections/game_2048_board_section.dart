import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_2048_bloc.dart';
import '../bloc/game_2048_event.dart';
import '../bloc/game_2048_state.dart';
import '../logic/game_2048_enums.dart';
import '../views/game_2048_tile_view.dart';
import 'game_2048_result_overlay.dart';

class Game2048BoardSection extends StatefulWidget {
  const Game2048BoardSection({super.key});

  @override
  State<Game2048BoardSection> createState() => _Game2048BoardSectionState();
}

class _Game2048BoardSectionState extends State<Game2048BoardSection> {
  Offset? _startPos;
  static const double _threshold = 24.0;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Game2048Bloc, Game2048State>(
      listenWhen: (p, c) {
        return c.spawnedTileIndices.isNotEmpty ||
            c.mergedTileIndices.isNotEmpty;
      },
      listener: (context, state) {
        // Schedule reset of animation metadata after frame
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<Game2048Bloc>().add(const Game2048AnimationConsumed());
        });
      },
      buildWhen: (p, c) => p.board != c.board,
      builder: (context, state) {
        if (state.board.isEmpty) return const SizedBox.shrink();

        return GestureDetector(
          onPanStart: (details) => _startPos = details.localPosition,
          onPanEnd: (details) {
            if (_startPos == null) return;
            // delta calculation is handled here if we needed complex paths,
            // but for swipe onPanEnd + simple coordinate check is fine if we use PanUpdate points.
            // Actually, we need delta. GestureDetector doesn't give delta on End easily without tracking.
            // I'll use onPanUpdate/End to get final position or just use onVertical/Horizontal with care.
            // Let's stick to the plan: PanStart and PanEnd.
          },
          // Refined gesture logic:
          onPanUpdate: (details) {
            if (_startPos == null) return;

            final delta = details.localPosition - _startPos!;
            if (delta.distance < _threshold) return;

            // Movement detected
            if (delta.dx.abs() > delta.dy.abs()) {
              _dispatchSwipe(
                delta.dx > 0 ? Game2048Direction.right : Game2048Direction.left,
              );
            } else {
              _dispatchSwipe(
                delta.dy > 0 ? Game2048Direction.down : Game2048Direction.up,
              );
            }
            _startPos = null; // Prevent multiple dispatches for one pan
          },
          child: AspectRatio(
            aspectRatio: 1,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBBADA0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                        ),
                    itemCount: 16,
                    itemBuilder: (context, index) {
                      return Game2048TileView(
                        value: state.board[index],
                        isNew: state.spawnedTileIndices.contains(index),
                        isMerged: state.mergedTileIndices.contains(index),
                      );
                    },
                  ),
                ),
                const Positioned.fill(child: Game2048ResultOverlay()),
              ],
            ),
          ),
        );
      },
    );
  }

  void _dispatchSwipe(Game2048Direction direction) {
    context.read<Game2048Bloc>().add(Game2048SwipeRequested(direction));
  }
}
