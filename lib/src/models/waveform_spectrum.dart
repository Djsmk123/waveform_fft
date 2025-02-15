/// Represents a frequency spectrum with minimum and maximum frequency values.
///
/// This class is used to define the frequency range of a waveform, typically
/// measured in Hertz (Hz). The spectrum is bounded by [min] and [max] values
/// which represent the lowest and highest frequencies in the range.
class FrequencySpectrum {
  /// Creates a new [FrequencySpectrum] with the specified minimum and maximum frequencies.
  ///
  /// [min] represents the lowest frequency in Hz
  /// [max] represents the highest frequency in Hz
  FrequencySpectrum(this.min, this.max);

  /// The minimum frequency value in Hz
  final int min;

  /// The maximum frequency value in Hz
  final int max;
}
