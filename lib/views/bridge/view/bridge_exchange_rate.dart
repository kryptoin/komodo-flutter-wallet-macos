import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rational/rational.dart';
import 'package:web_dex/bloc/bridge_form/bridge_bloc.dart';
import 'package:web_dex/bloc/bridge_form/bridge_state.dart';
import 'package:web_dex/mm2/mm2_api/rpc/best_orders/best_orders.dart';
import 'package:web_dex/views/dex/simple/form/exchange_info/exchange_rate.dart';

class BridgeExchangeRate extends StatelessWidget {
  const BridgeExchangeRate({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<BridgeBloc, BridgeState, BestOrder?>(
      selector: (state) => state.bestOrder,
      builder: (context, selectedOrder) {
        final String? base = context.read<BridgeBloc>().state.sellCoin?.abbr;
        final String? rel = selectedOrder?.coin;
        final Rational? rate = selectedOrder?.price;

        return ExchangeRate(
          rate: rate,
          base: base,
          rel: rel,
          showDetails: false,
        );
      },
    );
  }
}
