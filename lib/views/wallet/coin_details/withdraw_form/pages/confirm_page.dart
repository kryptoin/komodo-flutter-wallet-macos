import 'package:flutter/material.dart';
import 'package:web_dex/common/screen.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/send_confirm_form/send_confirm_footer.dart';
import 'package:web_dex/views/wallet/coin_details/withdraw_form/widgets/send_confirm_form/send_confirm_form.dart';

class ConfirmPage extends StatelessWidget {
  const ConfirmPage();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: isMobile
              ? const EdgeInsets.only(bottom: 12)
              : const EdgeInsets.only(top: 24, bottom: 22),
          child: const SendConfirmForm(),
        ),
        const SendConfirmFooter(),
        if (isMobile) const SizedBox(height: 20),
      ],
    );
  }
}
