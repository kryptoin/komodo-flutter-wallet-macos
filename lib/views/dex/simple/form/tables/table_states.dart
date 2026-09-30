import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:komodo_ui_kit/komodo_ui_kit.dart';
import 'package:web_dex/bloc/trading_status/trading_status_bloc.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';

/// Loading row used by the swap form's coin/order tables while their
/// backing data (geo status, best orders) is still being resolved.
class TableLoading extends StatelessWidget {
  const TableLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
      alignment: Alignment.center,
      child: const UiSpinner(),
    );
  }
}

/// Explains why a table cannot show data when the cause is not "no data",
/// e.g. the trading/geo status is still loading or trading is unavailable
/// in the user's location.
class TableMessage extends StatelessWidget {
  const TableMessage({required this.textKey, super.key});

  /// A [LocaleKeys] value to translate.
  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
      alignment: Alignment.center,
      child: Text(
        textKey.tr(),
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// Maps the current trading/geo status onto the placeholder that should be
/// shown instead of table content, or `null` when the data may be rendered.
///
/// The geo status gates every coin/order in these tables
/// (`prepareCoinsForTable` / `prepareOrdersForTable` return an empty list
/// until the check succeeds), so without this the user just sees a bare
/// "Nothing found" while the check is still running or after it failed.
Widget? tradingStatusPlaceholder(TradingStatusState tradingStatus) {
  if (tradingStatus is TradingStatusInitial ||
      tradingStatus is TradingStatusLoadInProgress) {
    return const TableLoading();
  }
  if (tradingStatus is TradingStatusLoadFailure) {
    return const TableMessage(textKey: LocaleKeys.loadingError);
  }
  if (!tradingStatus.isEnabled) {
    return const TableMessage(textKey: LocaleKeys.tradingDisabled);
  }
  return null;
}
