import 'package:game_2048/core/app_fonts.dart';
import 'package:game_2048/core/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_2048_bloc.dart';
import '../bloc/game_2048_event.dart';

class Game2048ActionsSection extends StatelessWidget {
  const Game2048ActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: () {
              context.read<Game2048Bloc>().add(
                const Game2048RestartRequested(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8F7A66),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              textStyle: context.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                fontFamily: AppFonts.clearSans,
              ),
            ),
            child: Text(context.l10n.game2048NewGame),
          ),
        ),
      ],
    );
  }
}
