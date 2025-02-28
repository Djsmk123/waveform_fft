import 'dart:async';
import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:waveform_fft/src/models/waveform_spectrum.dart';

class WaveFormWidgetEq extends StatefulWidget {
  final List<({FrequencySpectrum spectrum, double value})> data;
  final Duration animationDuration;
  final Duration updateInterval;
  final double barWidth;
  final double maxY;
  final double minY;
  final Color barColor;
  final double barAlpha;

  const WaveFormWidgetEq({
    super.key,
    required this.data,
    this.animationDuration = const Duration(milliseconds: 200),
    this.updateInterval = const Duration(milliseconds: 48),
    this.barWidth = 5,
    this.maxY = 80,
    this.minY = -80,
    this.barColor = Colors.white,
    this.barAlpha = 0.5,
  });

  @override
  State<WaveFormWidgetEq> createState() => _WaveFormWidgetEqState();
}

class _WaveFormWidgetEqState extends State<WaveFormWidgetEq>
    with SingleTickerProviderStateMixin {
  late List<double> animatedValues;
  late AnimationController _controller;
  late Timer _timer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();

    animatedValues =
        widget.data.isNotEmpty
            ? widget.data.map((e) => e.value).toList()
            : List.generate(30, (_) => _random.nextDouble() * 50 - 25);

    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    _timer = Timer.periodic(widget.updateInterval, (timer) {
      setState(() {
        if (animatedValues.isNotEmpty) {
          animatedValues.removeAt(0);
        }
        animatedValues.add(
          widget.data.isNotEmpty
              ? widget.data[(timer.tick % widget.data.length)].value
              : _random.nextDouble() * 50 - 25,
        );
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BarChart(
      BarChartData(
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        barTouchData: BarTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        maxY: widget.maxY,
        minY: widget.minY,
        barGroups: List.generate(animatedValues.length, (index) {
          double value = animatedValues[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                width: widget.barWidth,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    widget.barColor,
                    widget.barColor.withAlpha((widget.barAlpha * 255).toInt()),
                  ],
                ),
                toY: 3 * value.abs() * (1 - (value / (value + 15))),
                fromY: 3 * -value.abs() * (1 - (value / (value + 15))),
              ),
            ],
          );
        }),
      ),
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 180),
    );
  }
}
