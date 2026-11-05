import 'package:game_2048/core/app_fonts.dart';
import 'package:game_2048/core/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_2048_bloc.dart';
import '../bloc/game_2048_event.dart';
import '../bloc/game_2048_state.dart';
import '../logic/game_2048_enums.dart';

class Game2048ActionsSection extends StatelessWidget {
  const Game2048ActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Game2048Bloc, Game2048State>(
      buildWhen: (p, c) {
        return p.isAutoPlaying != c.isAutoPlaying ||
            p.status != c.status ||
            p.isOverlayVisible != c.isOverlayVisible;
      },
      builder: (context, state) {
        final canStartAutoPlay =
            state.status == Game2048SessionStatus.playing &&
            !state.isOverlayVisible;

        return Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: context.l10n.game2048NewGame,
                onPressed: () {
                  context.read<Game2048Bloc>().add(
                    const Game2048RestartRequested(),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ActionButton(
                label:
                    state.isAutoPlaying
                        ? context.l10n.game2048StopAutoPlay
                        : context.l10n.game2048AutoPlay,
                icon:
                    state.isAutoPlaying
                        ? Icons.stop_rounded
                        : Icons.smart_toy_outlined,
                highlighted: state.isAutoPlaying,
                onPressed:
                    state.isAutoPlaying || canStartAutoPlay
                        ? () {
                          context.read<Game2048Bloc>().add(
                            const Game2048AutoPlayToggled(),
                          );
                        }
                        : null,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool highlighted;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final text = Text(label);
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              highlighted ? const Color(0xFFF65E3B) : const Color(0xFF8F7A66),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFFBBADA0),
          disabledForegroundColor: Colors.white70,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          textStyle: context.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.clearSans,
          ),
        ),
        child:
            icon == null
                ? text
                : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 6),
                    text,
                  ],
                ),
      ),
    );
  }
}
