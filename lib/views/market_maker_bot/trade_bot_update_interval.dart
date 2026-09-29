enum TradeBotUpdateInterval {
  oneMinute,
  threeMinutes,
  fiveMinutes;

  @override
  String toString() {
    switch (this) {
      case TradeBotUpdateInterval.oneMinute:
        return '1';
      case TradeBotUpdateInterval.threeMinutes:
        return '3';
      case TradeBotUpdateInterval.fiveMinutes:
        return '5';
    }
  }

  static TradeBotUpdateInterval fromString(String interval) {
    switch (interval) {
      case '1':
        return TradeBotUpdateInterval.oneMinute;
      case '3':
        return TradeBotUpdateInterval.threeMinutes;
      case '5':
        return TradeBotUpdateInterval.fiveMinutes;
      case '60':
        return TradeBotUpdateInterval.oneMinute;
      case '180':
        return TradeBotUpdateInterval.threeMinutes;
      case '300':
        return TradeBotUpdateInterval.fiveMinutes;
      default:
        throw ArgumentError('Invalid interval');
    }
  }

  int get minutes {
    switch (this) {
      case TradeBotUpdateInterval.oneMinute:
        return 1;
      case TradeBotUpdateInterval.threeMinutes:
        return 3;
      case TradeBotUpdateInterval.fiveMinutes:
        return 5;
    }
  }

  int get seconds {
    switch (this) {
      case TradeBotUpdateInterval.oneMinute:
        return 60;
      case TradeBotUpdateInterval.threeMinutes:
        return 180;
      case TradeBotUpdateInterval.fiveMinutes:
        return 300;
    }
  }
}
