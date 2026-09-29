part of 'market_maker_order_list_bloc.dart';

sealed class MarketMakerOrderListEvent extends Equatable {
  const MarketMakerOrderListEvent();

  @override
  List<Object?> get props => [];
}

class MarketMakerOrderListRequested extends MarketMakerOrderListEvent {
  const MarketMakerOrderListRequested(this.updateInterval);

  final Duration updateInterval;

  @override
  List<Object> get props => [updateInterval];
}

class MarketMakerOrderListSortChanged extends MarketMakerOrderListEvent {
  const MarketMakerOrderListSortChanged(this.sortData);

  final SortData<MarketMakerBotOrderListType> sortData;

  @override
  List<Object> get props => [sortData];
}

class MarketMakerOrderListFilterChanged extends MarketMakerOrderListEvent {
  const MarketMakerOrderListFilterChanged(this.filterData);

  final TradingEntitiesFilter? filterData;

  @override
  List<Object?> get props => [filterData];
}
