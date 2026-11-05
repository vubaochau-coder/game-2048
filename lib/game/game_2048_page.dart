import 'package:game_2048/core/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/game_2048_bloc.dart';
import 'bloc/game_2048_event.dart';
import 'sections/game_2048_board_section.dart';
import 'sections/game_2048_header_section.dart';
import 'sections/game_2048_status_section.dart';
import 'sections/game_2048_actions_section.dart';

class Game2048Page extends StatelessWidget {
  const Game2048Page({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => Game2048Bloc()..add(const Game2048Started()),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8EF),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pageHorizontalPadding,
              vertical: AppSpacing.pageVerticalPadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Game2048HeaderSection(),
                SizedBox(height: 24),
                Game2048StatusSection(),
                SizedBox(height: 24),
                Game2048BoardSection(),
                SizedBox(height: 24),
                Game2048ActionsSection(),
                SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
