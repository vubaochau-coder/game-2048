import 'package:game_2048/core/app_fonts.dart';
import 'package:game_2048/core/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_2048_bloc.dart';
import '../bloc/game_2048_state.dart';

class Game2048StatusSection extends StatelessWidget {
  const Game2048StatusSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Game2048Bloc, Game2048State>(
      buildWhen: (p, c) => p.score != c.score || p.bestScore != c.bestScore,
      builder: (context, state) {
        return Row(
          children: [
            _ScoreBox(
              label: context.l10n.game2048Score,
              value: state.score.toString(),
            ),
            const SizedBox(width: 8),
            _ScoreBox(
              label:
                  'BEST', // Static since spec uses English for this label often
              value: state.bestScore.toString(),
            ),
          ],
        );
      },
    );
  }
}

class _ScoreBox extends StatelessWidget {
  final String label;
  final String value;

  const _ScoreBox({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF8F7A66),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: context.labelSmall.copyWith(
              color: const Color(0xFFEEE4DA),
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.clearSans,
            ),
          ),
          Text(
            value,
            style: context.titleLarge.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontFamily: AppFonts.clearSans,
            ),
          ),
        ],
      ),
    );
  }
}
