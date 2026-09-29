part of 'market_maker_bot_bloc.dart';

sealed class MarketMakerBotEvent extends Equatable {
  const MarketMakerBotEvent({this.botId = 0});

  /// The ID of the current bot configuration.
  final int botId;

  @override
  List<Object> get props => [botId];
}

/// Event to start the market maker bot with the current settings obtained from
/// [SettingsRepository]. If the bot is already running, the event is ignored.
class MarketMakerBotStartRequested extends MarketMakerBotEvent {
  const MarketMakerBotStartRequested();
}

/// Event to stop the market maker bot.
class MarketMakerBotStopRequested extends MarketMakerBotEvent {
  const MarketMakerBotStopRequested();
}

/// Event to update the market maker bot orders. All active orders are cancelled
/// and new orders are created based on the current market maker bot settings
/// obtained from [SettingsRepository].
class MarketMakerBotOrderUpdateRequested extends MarketMakerBotEvent {
  const MarketMakerBotOrderUpdateRequested(this.tradePair);

  final TradeCoinPairConfig tradePair;

  @override
  List<Object> get props => [botId, tradePair];
}

/// Event to cancel a market maker bot order. All active orders are cancelled
/// and new orders are created based on the current market maker bot settings
/// obtained from [SettingsRepository].
class MarketMakerBotOrderCancelRequested extends MarketMakerBotEvent {
  const MarketMakerBotOrderCancelRequested(this.tradePairs);

  final Iterable<TradeCoinPairConfig> tradePairs;

  @override
  List<Object> get props => [botId, tradePairs];
}
