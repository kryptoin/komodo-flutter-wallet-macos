import 'package:equatable/equatable.dart';
import 'package:web_dex/bloc/trading_kind/trading_kind.dart';

class TradingKindState extends Equatable {
  const TradingKindState({required this.kind});
  factory TradingKindState.initial() =>
      const TradingKindState(kind: TradingKind.taker);

  final TradingKind kind;
  bool get isMaker => kind == TradingKind.maker;
  bool get isTaker => kind == TradingKind.taker;

  @override
  List<Object?> get props => [kind];

  TradingKindState copyWith({TradingKind? kind}) {
    return TradingKindState(kind: kind ?? this.kind);
  }
}
