import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:web_dex/generated/codegen_loader.g.dart';
import 'package:web_dex/router/state/routing_state.dart';
import 'package:web_dex/views/common/page_header/page_header.dart';

class NftDetailsHeaderDesktop extends StatelessWidget {
  const NftDetailsHeaderDesktop({super.key});

  @override
  Widget build(BuildContext context) {
    return PageHeader(
      title: '',
      backText: LocaleKeys.collectibles.tr(),
      onBackButtonPressed: () => routingState.nftsState.reset(),
    );
  }
}
