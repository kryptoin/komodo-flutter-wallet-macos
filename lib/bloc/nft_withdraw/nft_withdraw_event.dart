part of 'nft_withdraw_bloc.dart';

abstract class NftWithdrawEvent {
  const NftWithdrawEvent();
}

class NftWithdrawAddressChanged extends NftWithdrawEvent {
  const NftWithdrawAddressChanged(this.address);
  final String address;
}

class NftWithdrawAmountChanged extends NftWithdrawEvent {
  const NftWithdrawAmountChanged(this.amount);
  final int? amount;
}

class NftWithdrawSendEvent extends NftWithdrawEvent {
  const NftWithdrawSendEvent();
}

class NftWithdrawConfirmSendEvent extends NftWithdrawEvent {
  const NftWithdrawConfirmSendEvent();
}

class NftWithdrawShowFillStep extends NftWithdrawEvent {
  const NftWithdrawShowFillStep();
}

class NftWithdrawInit extends NftWithdrawEvent {
  const NftWithdrawInit();
}

class NftWithdrawConvertAddress extends NftWithdrawEvent {
  const NftWithdrawConvertAddress();
}
