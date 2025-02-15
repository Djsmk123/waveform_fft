import 'dart:async';
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

  @override
  void initState() {
    super.initState();

    // Initialize with default values
    animatedValues = List.generate(
      widget.data.length,
      (index) => widget.data[index].value,
    );

    // Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    )..repeat(reverse: true);

    // Simulating real-time frequency updates
    _timer = Timer.periodic(widget.updateInterval, (timer) {
      if (widget.data.isEmpty) return; // Guard against empty data

      setState(() {
        // Shift bars left (looping effect)
        if (animatedValues.isNotEmpty) {
          animatedValues.removeAt(0);
        }
        animatedValues.add(
          widget.data[(timer.tick % widget.data.length)].value,
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
                    widget.barColor.withValues(alpha: widget.barAlpha),
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
