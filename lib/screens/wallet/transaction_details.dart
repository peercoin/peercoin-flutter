import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/available_coins.dart';
import '../../models/coin_wallet.dart';
import '../../models/wallet_transaction.dart';
import '../../tools/app_localizations.dart';
import '../../widgets/buttons.dart';

class TransactionDetails extends StatelessWidget {
  const TransactionDetails({Key? key}) : super(key: key);

  void _launchURL(String _url) async {
    await canLaunchUrlString(_url)
        ? await launchUrlString(
            _url,
          )
        : throw 'Could not launch $_url';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as List;
    final WalletTransaction _tx = args[0];
    final CoinWallet _coinWallet = args[1];
    final baseUrl =
        AvailableCoins.getSpecificCoin(_coinWallet.name).explorerUrl + '/tx/';
    final decimalProduct = AvailableCoins.getDecimalProduct(
      identifier: _coinWallet.name,
    );

    return Scaffold(
      appBar: AppBar(
          title: Text(
        AppLocalizations.instance.translate('transaction_details'),
      )),
      body: Align(
        child: PeerContainer(
          noSpacers: true,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('id'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(_tx.txid)
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(AppLocalizations.instance.translate('time'),
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  SelectableText(
                    _tx.timestamp! != 0
                        ? DateFormat().format(
                            DateTime.fromMillisecondsSinceEpoch(
                              _tx.timestamp! * 1000,
                            ),
                          )
                        : AppLocalizations.instance.translate('unconfirmed'),
                  )
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_value'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    (_tx.value / decimalProduct).toString() +
                        ' ' +
                        _coinWallet.letterCode,
                  )
                ],
              ),
              _tx.direction == 'out'
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          AppLocalizations.instance.translate('tx_fee'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(
                          (_tx.fee / decimalProduct).toString() +
                              ' ' +
                              _coinWallet.letterCode,
                        )
                      ],
                    )
                  : Container(),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_address'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(_tx.address),
                  // Text("") TODO might add address label here in the future
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_direction'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(_tx.direction)
                ],
              ),
              const Divider(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.instance.translate('tx_confirmations'),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SelectableText(
                    _tx.confirmations == -1
                        ? AppLocalizations.instance.translate('tx_rejected')
                        : _tx.confirmations.toString(),
                  )
                ],
              ),
              _tx.opReturn.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        Text(
                          AppLocalizations.instance.translate('send_op_return'),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SelectableText(_tx.opReturn)
                      ],
                    )
                  : Container(),
              const SizedBox(height: 20),
              Center(
                child: PeerButton(
                  action: () => _launchURL(baseUrl + _tx.txid),
                  text: AppLocalizations.instance
                      .translate('tx_view_in_explorer'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
