part of 'asset_overview_bloc.dart';

abstract class AssetOverviewEvent extends Equatable {
  const AssetOverviewEvent();

  @override
  List<Object> get props => [];
}

class AssetOverviewClearRequested extends AssetOverviewEvent {
  const AssetOverviewClearRequested();
}

class AssetOverviewLoadRequested extends AssetOverviewEvent {
  const AssetOverviewLoadRequested({
    required this.coin,
    required this.walletId,
  });

  final Coin coin;
  final String walletId;

  @override
  List<Object> get props => [coin, walletId];
}

class PortfolioAssetsOverviewLoadRequested extends AssetOverviewEvent {
  const PortfolioAssetsOverviewLoadRequested({
    required this.coins,
    required this.walletId,
  });

  final List<Coin> coins;
  final String walletId;

  @override
  List<Object> get props => [coins, walletId];
}

class AssetOverviewSubscriptionRequested extends AssetOverviewEvent {
  const AssetOverviewSubscriptionRequested({
    required this.coin,
    required this.walletId,
    required this.updateFrequency,
  });

  final Coin coin;
  final String walletId;
  final Duration updateFrequency;

  @override
  List<Object> get props => [coin, walletId, updateFrequency];
}

class PortfolioAssetsOverviewSubscriptionRequested extends AssetOverviewEvent {
  const PortfolioAssetsOverviewSubscriptionRequested({
    required this.coins,
    required this.walletId,
    required this.updateFrequency,
  });

  final List<Coin> coins;
  final String walletId;
  final Duration updateFrequency;

  @override
  List<Object> get props => [coins, walletId, updateFrequency];
}

class AssetOverviewUnsubscriptionRequested extends AssetOverviewEvent {}

class PortfolioAssetsOverviewUnsubscriptionRequested
    extends AssetOverviewEvent {}
