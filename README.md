# waveform_fft

A Flutter package for real-time audio visualization using FFT (Fast Fourier Transform). This package captures audio input and displays it as an animated waveform using fl_chart.

## Features

- Real-time audio capture and frequency analysis
- Customizable frequency spectrum ranges
- Smooth animated waveform visualization
- Support for different sample rates and buffer sizes
- Easy-to-use API

## Getting Started

### Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  waveform_fft: ^0.0.1
```

### Platform Setup

#### Android

Add the following permissions to your `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

#### iOS

Add the following keys to your `ios/Runner/Info.plist`:

```xml
<key>NSMicrophoneUsageDescription</key>
<string>This app needs access to microphone to visualize audio.</string>
```

### Customizing the Waveform

The `WaveFormWidgetEq` widget accepts several parameters for customization:

```dart
WaveFormWidgetEq(
  data: data,                                           // Frequency data
  animationDuration: Duration(milliseconds: 200),       // Animation speed
  updateInterval: Duration(milliseconds: 48),           // Update frequency
  barWidth: 5.0,                                       // Width of each bar
  maxY: 80.0,                                          // Maximum Y value
  minY: -80.0,                                         // Minimum Y value
  barColor: Colors.white,                              // Color of bars
  barAlpha: 0.5,                                       // Opacity of bars
);
```

### Audio Capture Service

The `AudioCaptureService` can be customized with different sample rates and buffer sizes:

```dart
final service = AudioCaptureService(
  sampleRate: 44100,    // Default: 44100 Hz
  bufferSize: 256,      // Default: 256 samples
);
```

> **Note:** The `AudioCaptureService` is a singleton and should be initialized once in your application.

## Example

Here's a demo of the audio visualization in action:

[![Audio Visualization Demo](https://img.youtube.com/vi/xs3dE7HB4GU/0.jpg)](https://youtube.com/shorts/xs3dE7HB4GU)

The example above demonstrates:

- Real-time audio capture from device microphone
- FFT processing of audio data
- Animated waveform visualization
- Responsive UI with start/stop recording controls

Check out the complete example code in the `/example` directory to see how to implement this in your app.

### Frequency Spectrum

The package includes predefined frequency spectrum ranges from 0Hz to 22kHz, following standard audio frequency bands. You can customize these ranges by modifying the `AudioWaveFormConstants.defaultFrequencySpectrum`.

### Performance Considerations

- Higher sample rates provide better frequency resolution but require more processing power
- Smaller buffer sizes reduce latency but may cause performance issues
- Consider device capabilities when adjusting these parameters

## Compatibility

- Android: API 21+
- iOS: iOS 13.0+
- If you do not want to use raw audio data by microphone then you can use any other flutter package like `record`  or `flutter_sound` etc for audio recording purpose.

## License

[MIT](https://opensource.org/licenses/MIT)

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Inspiration


- [Blog](https://medium.com/neusta-mobile-solutions/master-real-time-frequency-extraction-in-flutter-to-elevate-your-app-experience-f5fef9017f09)
