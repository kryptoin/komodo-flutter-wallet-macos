import 'package:flutter/material.dart';
import 'package:web_dex/model/coin.dart';
import 'package:web_dex/shared/utils/formatters.dart';
import 'package:web_dex/shared/utils/utils.dart';
import 'package:web_dex/shared/widgets/copyable_link.dart';

class HashExplorerLink extends StatelessWidget {
  const HashExplorerLink({
    super.key,
    required this.coin,
    required this.hash,
    required this.type,
  });
  final Coin coin;
  final String hash;
  final HashExplorerType type;

  @override
  Widget build(BuildContext context) {
    return CopyableLink(
      text: truncateMiddleSymbols(hash),
      valueToCopy: hash,
      onLinkTap: () => viewHashOnExplorer(coin, hash, type),
    );
  }
}
