part of 'nft_transactions_bloc.dart';

abstract class NftTxnEvent extends Equatable {
  const NftTxnEvent();

  @override
  List<Object> get props => [];
}

class NftTxnReceiveEvent extends NftTxnEvent {
  final bool withAdditionalData;
  const NftTxnReceiveEvent([this.withAdditionalData = false]);
}

class NftTxReceiveDetailsEvent extends NftTxnEvent {
  const NftTxReceiveDetailsEvent(this.tx);

  final NftTransaction tx;

  @override
  List<Object> get props => [tx];
}

class NftTxnEventNoLogin extends NftTxnEvent {
  const NftTxnEventNoLogin();
}

class NftTxnEventSearchChanged extends NftTxnEvent {
  const NftTxnEventSearchChanged(this.searchLine);

  final String searchLine;

  @override
  List<Object> get props => [searchLine];
}

class NftTxnEventStatusesChanged extends NftTxnEvent {
  const NftTxnEventStatusesChanged(this.statuses);

  final List<NftTransactionStatuses> statuses;

  @override
  List<Object> get props => [statuses];
}

class NftTxnEventBlockchainChanged extends NftTxnEvent {
  const NftTxnEventBlockchainChanged(this.blockchains);

  final List<NftBlockchains> blockchains;

  @override
  List<Object> get props => [blockchains];
}

class NftTxnEventStartDateChanged extends NftTxnEvent {
  const NftTxnEventStartDateChanged(this.dateFrom);

  final DateTime? dateFrom;

  @override
  List<Object> get props => [dateFrom ?? DateTime(2010)];
}

class NftTxnEventEndDateChanged extends NftTxnEvent {
  const NftTxnEventEndDateChanged(this.dateTo);

  final DateTime? dateTo;

  @override
  List<Object> get props => [dateTo ?? DateTime(2010)];
}

class NftTxnEventFullFilterChanged extends NftTxnEvent {
  const NftTxnEventFullFilterChanged(this.filter);

  final NftTransactionsFilter filter;

  @override
  List<Object> get props => [filter];
}

class NftTxnClearFilters extends NftTxnEvent {
  const NftTxnClearFilters();
}
