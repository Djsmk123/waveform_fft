/// This example demonstrates how to use the waveform_fft package to create a real-time
/// audio visualization app. The app captures audio input and displays it as an animated
/// waveform using the WaveFormWidgetEq widget.
///
/// Key features shown:
/// - Real-time audio capture using AudioCaptureService
/// - Smooth waveform animation using Ticker
/// - Material 3 theming and responsive UI
/// - Permission handling for microphone access
///
/// See the README.md for more details on setup and customization options.
library;

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:waveform_fft/waveform_fft.dart';

void main() {
  runApp(const MyApp());
}

/// Root widget that sets up the MaterialApp with theme configuration
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Waveform Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6750A4),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const WaveformPage(),
    );
  }
}

/// Main page widget that handles the audio visualization UI and logic
class WaveformPage extends StatefulWidget {
  const WaveformPage({super.key});

  @override
  State<WaveformPage> createState() => _WaveformPageState();
}

/// State for WaveformPage that manages audio capture and animation
class _WaveformPageState extends State<WaveformPage>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  List<({FrequencySpectrum spectrum, double value})> data = [];
  List<({FrequencySpectrum spectrum, double value})> data2Animation = [];
  bool isRecording = false;
  final AudioCaptureService _audioCaptureService = AudioCaptureService();

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      if (data2Animation.isEmpty) {
        data2Animation = data;
      } else {
        for (int i = 0; i < data.length; i++) {
          data2Animation[i] = (
            spectrum: data2Animation[i].spectrum,
            value: lerpDouble(data2Animation[i].value, data[i].value, 0.1)!,
          );
        }
      }
      setState(() {});
    });
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          'Audio Visualizer',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [theme.colorScheme.surface, theme.colorScheme.surface],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Visualize Your Sound',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Start recording to see the magic happen',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: .7),
                  ),
                ),
                const SizedBox(height: 48),
                if (isRecording)
                  SizedBox(
                    height: 200,
                    width: MediaQuery.sizeOf(context).width,
                    child: WaveFormWidgetEq(
                      data: data2Animation,
                      barWidth: 4,
                      maxY: 80,
                      minY: -80,
                      barColor: theme.colorScheme.primary,
                      barAlpha: 0.6,
                      animationDuration: const Duration(milliseconds: 120),
                      updateInterval: const Duration(milliseconds: 48),
                    ),
                  ),
                const SizedBox(height: 48),
                FilledButton.icon(
                  onPressed: () {
                    isRecording = !isRecording;
                    if (isRecording) {
                      _audioCaptureService.startCapture((data) {
                        setState(() {
                          this.data = data;
                        });
                      });
                    } else {
                      _audioCaptureService.stopCapture();
                    }
                    setState(() {});
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  label: Text(
                    isRecording ? 'Stop Recording' : 'Start Recording',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
