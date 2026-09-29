enum TradeVolumeType {
  /// The volume is in USD
  usd,

  /// The volume is a percentage of the total balance as a decimal value.
  /// For example, 0.5 is 50% of the total balance.
  percentage;

  String get symbol => this == TradeVolumeType.usd ? '\$' : '%';

  String get name => this == TradeVolumeType.usd ? 'USD' : 'Percentage';

  String get title => name;

  static String getTitle(TradeVolumeType volumeType) {
    return volumeType.title;
  }
}
