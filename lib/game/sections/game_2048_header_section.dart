import 'package:game_2048/core/app_fonts.dart';
import 'package:game_2048/core/context_ext.dart';
import 'package:flutter/material.dart';

class Game2048HeaderSection extends StatelessWidget {
  const Game2048HeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2048',
          style: context.headlineLarge.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.clearSans,
            color: const Color(0xFF776E65),
          ),
        ),
        Text(
          context.l10n.game2048Subtitle,
          style: context.bodyMedium.copyWith(
            color: context.color.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
