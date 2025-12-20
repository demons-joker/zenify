import 'dart:math';
import 'package:flutter/material.dart';

class RandomWordCloud extends StatelessWidget {
  final List<Map<String, dynamic>> words;
  final double containerHeight;

  const RandomWordCloud({
    super.key,
    required this.words,
    this.containerHeight = 150,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: containerHeight,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return _WordCloudPainter(
            words: words,
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight,
          );
        },
      ),
    );
  }
}

class _WordCloudPainter extends StatefulWidget {
  final List<Map<String, dynamic>> words;
  final double maxWidth;
  final double maxHeight;

  const _WordCloudPainter({
    required this.words,
    required this.maxWidth,
    required this.maxHeight,
  });

  @override
  State<_WordCloudPainter> createState() => _WordCloudPainterState();
}

class _WordCloudPainterState extends State<_WordCloudPainter> {
  late final Random _random;
  late List<_PositionedWord> _positionedWords;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _positionedWords = _calculatePositions();
  }

  List<_PositionedWord> _calculatePositions() {
    final List<_PositionedWord> result = [];
    final maxAttempts = 50;

    for (final word in widget.words) {
      final isHighlighted = word['highlight'] == true;
      var fontSize = isHighlighted
          ? 14.0 + _random.nextDouble() * 6
          : 12.0 + _random.nextDouble() * 4;

      final text = word['text']?.toString() ?? '';
      var textPainter = _createTextPainter(text, fontSize, isHighlighted);

      Offset? position;
      int attempts = 0;

      while (position == null && attempts < maxAttempts) {
        final candidatePosition = Offset(
          _random.nextDouble() * (widget.maxWidth - textPainter.width),
          _random.nextDouble() * (widget.maxHeight - textPainter.height),
        );

        final candidateRect = Rect.fromLTWH(
          candidatePosition.dx,
          candidatePosition.dy,
          textPainter.width,
          textPainter.height,
        );

        final overlaps =
            result.any((placedWord) => placedWord.rect.overlaps(candidateRect));

        if (!overlaps) {
          position = candidatePosition;
        } else {
          attempts++;
          // 尝试缩小字体
          if (attempts % 10 == 0) {
            fontSize *= 0.9;
            textPainter = _createTextPainter(text, fontSize, isHighlighted);
          }
        }
      }

      // 如果找不到位置，放在第一个可用位置或左上角
      position ??=
          _findFirstAvailablePosition(textPainter, result) ?? Offset.zero;

      result.add(_PositionedWord(
        text: text,
        position: position,
        fontSize: fontSize,
        isHighlighted: isHighlighted,
        rect: Rect.fromLTWH(
          position.dx,
          position.dy,
          textPainter.width,
          textPainter.height,
        ),
      ));
    }

    return result;
  }

  Offset? _findFirstAvailablePosition(
    TextPainter textPainter,
    List<_PositionedWord> placedWords,
  ) {
    const gridSize = 20.0; // 网格化搜索步长
    for (double y = 0;
        y < widget.maxHeight - textPainter.height;
        y += gridSize) {
      for (double x = 0;
          x < widget.maxWidth - textPainter.width;
          x += gridSize) {
        final candidateRect = Rect.fromLTWH(
          x,
          y,
          textPainter.width,
          textPainter.height,
        );

        final overlaps =
            placedWords.any((word) => word.rect.overlaps(candidateRect));
        if (!overlaps) {
          return Offset(x, y);
        }
      }
    }
    return null;
  }

  TextPainter _createTextPainter(
      String text, double fontSize, bool isHighlighted) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          color:
              isHighlighted ? const Color(0xFFFF802C) : const Color(0xFFC7C7C7),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _positionedWords.map((word) {
        return Positioned(
          left: word.position.dx,
          top: word.position.dy,
          child: Text(
            word.text,
            style: TextStyle(
              fontSize: word.fontSize,
              color: word.isHighlighted
                  ? const Color(0xFFFF802C)
                  : const Color(0xFFC7C7C7),
              fontWeight:
                  word.isHighlighted ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _PositionedWord {
  final String text;
  final Offset position;
  final double fontSize;
  final bool isHighlighted;
  final Rect rect;

  _PositionedWord({
    required this.text,
    required this.position,
    required this.fontSize,
    required this.isHighlighted,
    required this.rect,
  });
}
