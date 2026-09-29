import 'package:formz/formz.dart';
import 'package:rational/rational.dart';

enum AmountValidationError {
  /// Input is empty
  empty,

  /// Not a valid number
  invalid,

  /// Number is greater than the available balance
  moreThanMaximum,

  /// Number is less than the minimum required amount. Defaults to 0.
  lessThanMinimum,
}

class CoinTradeAmountInput extends FormzInput<String, AmountValidationError> {
  const CoinTradeAmountInput.pure([
    String value = '0',
    this.minAmount = 0,
    this.maxAmount = double.infinity,
  ]) : super.pure(value);
  const CoinTradeAmountInput.dirty([
    String value = '',
    this.minAmount = 0,
    this.maxAmount = double.infinity,
  ]) : super.dirty(value);

  final double minAmount;
  final double maxAmount;

  Rational get valueAsRational {
    final amount = double.tryParse(value) ?? 0;
    return Rational.parse(amount.toString());
  }

  @override
  AmountValidationError? validator(String value) {
    if (value.isEmpty) {
      return AmountValidationError.empty;
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return AmountValidationError.invalid;
    }

    if (amount < minAmount) {
      return AmountValidationError.lessThanMinimum;
    }

    if (amount > maxAmount) {
      return AmountValidationError.moreThanMaximum;
    }

    return null;
  }
}
