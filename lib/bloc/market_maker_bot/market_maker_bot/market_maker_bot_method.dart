enum MarketMakerBotMethod {
  start,
  stop;

  String get value {
    switch (this) {
      case MarketMakerBotMethod.start:
        return 'start_simple_market_maker_bot';
      case MarketMakerBotMethod.stop:
        return 'stop_simple_market_maker_bot';
    }
  }
}
