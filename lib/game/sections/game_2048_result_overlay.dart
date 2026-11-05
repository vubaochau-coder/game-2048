import 'package:game_2048/core/app_fonts.dart';
import 'package:game_2048/core/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_2048_bloc.dart';
import '../bloc/game_2048_event.dart';
import '../bloc/game_2048_state.dart';
import '../logic/game_2048_enums.dart';

class Game2048ResultOverlay extends StatelessWidget {
  const Game2048ResultOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<Game2048Bloc, Game2048State>(
      buildWhen: (p, c) {
        return p.status != c.status ||
            p.isOverlayVisible != c.isOverlayVisible ||
            p.hasDismissedWinOverlay != c.hasDismissedWinOverlay;
      },
      builder: (context, state) {
        return IgnorePointer(
          ignoring: !state.isOverlayVisible,
          child: AnimatedOpacity(
            opacity: state.isOverlayVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeIn,
            child: Container(
              decoration: BoxDecoration(
                color:
                    state.status == Game2048SessionStatus.won
                        ? const Color(0x80EDC22E)
                        : const Color(0x80EEE4DA),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 90),
                  _MessageText(
                    text:
                        state.status == Game2048SessionStatus.won
                            ? context.l10n.game2048YouWin
                            : context.l10n.game2048GameOver,
                    color:
                        state.status == Game2048SessionStatus.won
                            ? const Color(0xFFF9F6F2)
                            : const Color(0xFF776E65),
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _ActionButtons(status: state.status),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MessageText extends StatelessWidget {
  final String text;
  final Color color;

  const _MessageText({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: color,
          fontFamily: AppFonts.clearSans,
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final Game2048SessionStatus status;

  const _ActionButtons({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == Game2048SessionStatus.won) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _OverlayButton(
            text: context.l10n.game2048TryAgain,
            onPressed: () {
              context.read<Game2048Bloc>().add(
                const Game2048TryAgainRequested(),
              );
            },
          ),
          const SizedBox(width: 9),
          _OverlayButton(
            text: context.l10n.game2048KeepGoing,
            onPressed: () {
              context.read<Game2048Bloc>().add(
                const Game2048ContinueAfterWinRequested(),
              );
            },
          ),
        ],
      );
    } else {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _OverlayButton(
            text: context.l10n.game2048TryAgain,
            onPressed: () {
              context.read<Game2048Bloc>().add(
                const Game2048TryAgainRequested(),
              );
            },
          ),
        ],
      );
    }
  }
}

class _OverlayButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _OverlayButton({required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFF8F7A66),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFFF9F6F2),
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: AppFonts.clearSans,
          ),
        ),
      ),
    );
  }
}
