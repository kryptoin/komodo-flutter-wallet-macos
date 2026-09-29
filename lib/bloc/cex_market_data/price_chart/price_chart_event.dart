import 'package:equatable/equatable.dart';

sealed class PriceChartEvent extends Equatable {
  const PriceChartEvent();

  @override
  List<Object> get props => [];
}

final class PriceChartStarted extends PriceChartEvent {
  final List<String> symbols;
  final Duration period;

  const PriceChartStarted({required this.symbols, required this.period});

  @override
  List<Object> get props => [symbols, period];
}

final class PriceChartPeriodChanged extends PriceChartEvent {
  final Duration period;

  const PriceChartPeriodChanged(this.period);

  @override
  List<Object> get props => [period];
}

final class PriceChartCoinsSelected extends PriceChartEvent {
  final List<String> symbols;

  const PriceChartCoinsSelected(this.symbols);

  @override
  List<Object> get props => [symbols];
}
