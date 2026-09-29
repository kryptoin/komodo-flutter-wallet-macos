import 'package:formz/formz.dart';

enum TradeVolumeValidationError {
  /// The percentage is invalid
  invalidPercentage,
}

/// Formz input for the trade volume limit.
class TradeVolumeInput extends FormzInput<double, TradeVolumeValidationError> {
  const TradeVolumeInput.pure(double value) : super.pure(value);
  const TradeVolumeInput.dirty(double value) : super.dirty(value);

  @override
  TradeVolumeValidationError? validator(double value) {
    if (value < 0.0 || value > 1.0) {
      return TradeVolumeValidationError.invalidPercentage;
    }
    return null;
  }
}
