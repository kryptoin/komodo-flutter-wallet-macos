import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web_dex/bloc/taker_form/taker_bloc.dart';
import 'package:web_dex/bloc/taker_form/taker_state.dart';
import 'package:web_dex/model/trade_preimage.dart';
import 'package:web_dex/views/dex/simple/form/exchange_info/total_fees.dart';

class TakerFormTotalFees extends StatelessWidget {
  const TakerFormTotalFees();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<TakerBloc, TakerState, TradePreimage?>(
      selector: (state) => state.tradePreimage,
      builder: (context, tradePreimage) {
        return TotalFees(preimage: tradePreimage);
      },
    );
  }
}
