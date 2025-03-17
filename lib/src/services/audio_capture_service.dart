import 'dart:async';
import 'dart:typed_data';

import 'package:fftea/fftea.dart';
import 'package:waveform_fft/src/models/waveform_spectrum.dart';
import 'package:waveform_fft/src/utils/contants.dart';
import 'package:flutter_audio_capture_v2/flutter_audio_capture_v2.dart';

/// Service responsible for capturing and analyzing audio input in real-time.
///
/// This service uses [FlutterAudioCapture] to record audio and performs Fast Fourier Transform (FFT)
/// to analyze the frequency spectrum of the captured audio.
class AudioCaptureService {
  /// Creates an [AudioCaptureService] with optional sample rate and buffer size parameters.
  ///
  /// [sampleRate] - The number of samples per second (default: 44100 Hz)
  /// [bufferSize] - The size of the audio buffer (default: 256 samples)
  AudioCaptureService({this.sampleRate = 44100, this.bufferSize = 256}) {
    initialize();
  }

  /// The sample rate in Hz for audio capture
  final int sampleRate;

  /// The buffer size in samples for audio processing
  final int bufferSize;

  final Completer<bool> _isInitialized = Completer();
  final FlutterAudioCapture _flutterAudioCapture = FlutterAudioCapture();
  List<FrequencySpectrum> _frequencySpectrum = [];

  /// Initializes the audio capture service.
  ///
  /// Throws an exception if initialization fails.
  Future<void> initialize() async {
    final isInitialized = await _flutterAudioCapture.init();
    if (isInitialized == null || !isInitialized) {
      throw Exception('Failed to initialize FlutterAudioCapture');
    }
    _frequencySpectrum = AudioWaveFormConstants.defaultFrequencySpectrum;
    _isInitialized.complete(true);
  }

  /// Sets the frequency spectrum ranges for analysis.
  set frequencySpectrum(List<FrequencySpectrum> value) {
    _frequencySpectrum = value;
  }

  /// Starts capturing and analyzing audio input.
  ///
  /// [onData] callback is called with frequency analysis results for each audio buffer.
  /// Each result contains the frequency spectrum and its corresponding magnitude value.
  Future<void> startCapture(void Function(List<({FrequencySpectrum spectrum, double value})> data) onData) async {
    await _isInitialized.future;

    _flutterAudioCapture.start(
      (Float32List buffer) {
        final fft = FFT(buffer.length);
        final frequencies = fft.realFft(buffer);
        final magnitudes = frequencies.discardConjugates().magnitudes().toList();

        final frequencyValues =
            _frequencySpectrum.map((spectrum) {
              final minIndex = fft.indexOfFrequency(spectrum.min.toDouble(), sampleRate.toDouble());
              final maxIndex = fft.indexOfFrequency(spectrum.max.toDouble(), sampleRate.toDouble());

              final value = magnitudes.sublist(minIndex.floor(), maxIndex.ceil()).reduce((a, b) => a + b);

              return (spectrum: spectrum, value: value);
            }).toList();

        onData(frequencyValues);
      },
      (error) => throw Exception(error),
      sampleRate: sampleRate,
      bufferSize: bufferSize,
    );
  }

  /// Stops the audio capture.
  Future<void> stopCapture() async {
    await _flutterAudioCapture.stop();
  }
}
