import 'package:game_2048/core/app_fonts.dart';
import 'package:flutter/material.dart';

class Game2048TileView extends StatefulWidget {
  final int value;
  final bool isNew;
  final bool isMerged;

  const Game2048TileView({
    super.key,
    required this.value,
    this.isNew = false,
    this.isMerged = false,
  });

  @override
  State<Game2048TileView> createState() => _Game2048TileViewState();
}

class _Game2048TileViewState extends State<Game2048TileView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = TweenSequence<double>([
      if (widget.isMerged) ...[
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
        TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
      ] else if (widget.isNew) ...[
        TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 100),
      ] else ...[
        TweenSequenceItem(tween: ConstantTween(1.0), weight: 100),
      ],
    ]).animate(_controller);

    if (widget.isNew || widget.isMerged) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(Game2048TileView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isNew || widget.isMerged) {
      _scaleAnimation = TweenSequence<double>([
        if (widget.isMerged) ...[
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.2), weight: 50),
          TweenSequenceItem(tween: Tween(begin: 1.2, end: 1.0), weight: 50),
        ] else if (widget.isNew) ...[
          TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 100),
        ] else ...[
          TweenSequenceItem(tween: ConstantTween(1.0), weight: 100),
        ],
      ]).animate(_controller);
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: _getBackgroundColor(widget.value),
          borderRadius: BorderRadius.circular(3),
        ),
        child:
            widget.value == 0
                ? null
                : Center(
                  child: Text(
                    widget.value.toString(),
                    style: TextStyle(
                      fontSize: _getFontSize(widget.value),
                      fontWeight: FontWeight.bold,
                      color: _getTextColor(widget.value),
                      fontFamily: AppFonts.clearSans,
                    ),
                  ),
                ),
      ),
    );
  }

  Color _getBackgroundColor(int value) {
    switch (value) {
      case 2:
        return const Color(0xFFEEE4DA);
      case 4:
        return const Color(0xFFEDE0C8);
      case 8:
        return const Color(0xFFF2B179);
      case 16:
        return const Color(0xFFF59563);
      case 32:
        return const Color(0xFFF67C5F);
      case 64:
        return const Color(0xFFF65E3B);
      case 128:
        return const Color(0xFFEDCF72);
      case 256:
        return const Color(0xFFEDCC61);
      case 512:
        return const Color(0xFFEDC850);
      case 1024:
        return const Color(0xFFEDC53F);
      case 2048:
        return const Color(0xFFEDC22E);
      default:
        return const Color(0x59EEE4DA);
    }
  }

  Color _getTextColor(int value) {
    if (value <= 4) return const Color(0xFF776E65);
    return const Color(0xFFF9F6F2);
  }

  double _getFontSize(int value) {
    final s = value.toString();
    if (s.length <= 2) return 35;
    if (s.length == 3) return 25;
    if (s.length == 4) return 15;
    return 10;
  }
}
