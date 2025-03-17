import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:waveform_fft/src/models/waveform_spectrum.dart';

class CustomWaveFormWidgetEq extends StatefulWidget {
  final List<({FrequencySpectrum spectrum, double value})> data;
  final Duration animationDuration;
  final Duration updateInterval;
  final double barWidth;
  final double maxY;
  final double minY;
  final Color barColor;
  final double barAlpha;

  const CustomWaveFormWidgetEq({
    super.key,
    required this.data,
    this.animationDuration = const Duration(milliseconds: 200),
    this.updateInterval = const Duration(milliseconds: 32),
    this.barWidth = 5,
    this.maxY = 80,
    this.minY = -80,
    this.barColor = Colors.white,
    this.barAlpha = 0.5,
  });

  @override
  State<CustomWaveFormWidgetEq> createState() => _CustomWaveFormWidgetEqState();
}

class _CustomWaveFormWidgetEqState extends State<CustomWaveFormWidgetEq> with TickerProviderStateMixin {
  final List<AnimatedBar> _bars = [];
  late Timer _timer;
  final Random _random = Random();
  int _dataIndex = 0;

  @override
  void initState() {
    super.initState();

    // Timer to add new bars
    _timer = Timer.periodic(widget.updateInterval, (timer) {
      _addNewBar();
    });
  }

  void _addNewBar() {
    if (!mounted) return;

    // Get the new value
    final double newValue =
        widget.data.isNotEmpty
            ? widget.data[_dataIndex % widget.data.length].value
            : _random.nextDouble() * (widget.maxY - widget.minY) + widget.minY;

    _dataIndex++;

    // Get the last bar's value for smoother transition
    final double previousValue = _bars.isNotEmpty ? _bars.last.targetValue : 0.0;

    // Create a new animation controller
    final AnimationController controller = AnimationController(vsync: this, duration: widget.animationDuration);

    // Create the animation with improved easing
    final Animation<double> animation = Tween<double>(
      begin: previousValue, // Start from the last bar value
      end: newValue,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.linearToEaseOut));

    final AnimatedBar newBar = AnimatedBar(targetValue: newValue, animation: animation, controller: controller);

    setState(() {
      _bars.add(newBar);

      // Remove old bars smoothly
      if (_bars.length > 100) {
        final oldBar = _bars.removeAt(0);
        oldBar.controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  void dispose() {
    _timer.cancel();
    for (final bar in _bars) {
      bar.controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return ClipRect(
          child: CustomPaint(
            painter: WaveformPainter(
              bars: _bars,
              barWidth: widget.barWidth,
              maxY: widget.maxY,
              minY: widget.minY,
              barColor: widget.barColor,
              barAlpha: widget.barAlpha,
              availableWidth: constraints.maxWidth,
            ),
            size: Size(constraints.maxWidth, constraints.maxHeight),
          ),
        );
      },
    );
  }
}

class AnimatedBar {
  final double targetValue;
  final Animation<double> animation;
  final AnimationController controller;

  AnimatedBar({required this.targetValue, required this.animation, required this.controller});
}

class WaveformPainter extends CustomPainter {
  final List<AnimatedBar> bars;
  final double barWidth;
  final double maxY;
  final double minY;
  final Color barColor;
  final double barAlpha;
  final double availableWidth;

  WaveformPainter({
    required this.bars,
    required this.barWidth,
    required this.maxY,
    required this.minY,
    required this.barColor,
    required this.barAlpha,
    required this.availableWidth,
  }) : super(repaint: Listenable.merge(bars.map((bar) => bar.animation).toList()));

  @override
  void paint(Canvas canvas, Size size) {
    final double spacing = 3.0; // Space between bars
    final double totalBarWidth = barWidth + spacing;
    final double centerY = size.height / 2;

    // Calculate how many bars we can fit
    final int maxBars = (availableWidth / totalBarWidth).floor();

    // Start from the rightmost position
    double x = availableWidth - barWidth;

    // Draw from newest to oldest (right to left)
    for (int i = bars.length - 1; i >= 0 && i >= bars.length - maxBars; i--) {
      final AnimatedBar bar = bars[i];
      final double value = bar.animation.value;

      // Calculate positive and negative parts of the bar
      final double positiveHeight = 3 * value.abs() * (1 - (value / (value + 15)));
      final double negativeHeight = 3 * -value.abs() * (1 - (value / (value + 15)));

      // Scale heights to fit within the available height
      final double scaleFactor = size.height / (maxY - minY);
      final double topY = centerY - (positiveHeight * scaleFactor);
      final double bottomY = centerY - (negativeHeight * scaleFactor);

      // Create gradient for the bar
      final Paint barPaint =
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [barColor, barColor.withAlpha((barAlpha * 255).toInt())],
            ).createShader(Rect.fromPoints(Offset(x, topY), Offset(x + barWidth, bottomY)));

      // Draw the bar
      canvas.drawRect(Rect.fromPoints(Offset(x, topY), Offset(x + barWidth, bottomY)), barPaint);

      // Move to the next position (left)
      x -= totalBarWidth;
    }
  }

  @override
  bool shouldRepaint(covariant WaveformPainter oldDelegate) {
    return oldDelegate.barWidth != barWidth ||
        oldDelegate.maxY != maxY ||
        oldDelegate.minY != minY ||
        oldDelegate.barColor != barColor ||
        oldDelegate.barAlpha != barAlpha ||
        oldDelegate.availableWidth != availableWidth;
  }
}
