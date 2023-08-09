import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:peercoin/providers/app_settings.dart';
import 'package:provider/provider.dart';

import '../../../providers/connection.dart';
import '../../../providers/wallet_provider.dart';
import '../../../tools/app_localizations.dart';
import '../../../tools/app_routes.dart';
import '../../../tools/background_sync.dart';
import '../../../tools/logger_wrapper.dart';
import '../../../widgets/buttons.dart';
import '../../../widgets/loading_indicator.dart';

class AppSettingsWalletScanLandingScreen extends StatefulWidget {
  const AppSettingsWalletScanLandingScreen({Key? key}) : super(key: key);

  @override
  State<AppSettingsWalletScanLandingScreen> createState() =>
      _AppSettingsWalletScanLandingScreenState();
}

class _AppSettingsWalletScanLandingScreenState
    extends State<AppSettingsWalletScanLandingScreen> {
  bool _initial = true;
  bool _scanStarted = false;
  bool _backgroundNotificationsAvailable = false;
  ConnectionProvider? _connectionProvider;
  late WalletProvider _walletProvider;
  late AppSettings _settings;
  late String _coinName = '';
  late BackendConnectionState _connectionState;
  late int _walletNumber;
  int _latestUpdate = 0;
  int _addressScanPointer = 0;
  int _addressChunkSize = 10;
  late Timer _timer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          AppLocalizations.instance.translate(
            'wallet_scan_appBar_title',
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LoadingIndicator(),
          const SizedBox(height: 20),
          Text(
            AppLocalizations.instance.translate('wallet_scan_notice'),
          ),
          if (_backgroundNotificationsAvailable == false && !kIsWeb)
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    AppLocalizations.instance.translate(
                      'wallet_scan_notice_bg_notifications',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
          PeerButton(
            text: AppLocalizations.instance
                .translate('server_settings_alert_cancel'),
            action: () async {
              _timer.cancel();
              await Navigator.of(context).pushReplacementNamed(
                Routes.walletList,
              );
            },
          )
        ],
      ),
    );
  }

  @override
  void deactivate() async {
    await _connectionProvider!.closeConnection();
    _timer.cancel();
    super.deactivate();
  }

  @override
  void didChangeDependencies() async {
    if (_initial == true) {
      _settings = Provider.of<AppSettings>(context, listen: false);
      setState(() {
        _initial = false;
        _backgroundNotificationsAvailable = _settings.notificationInterval > 0;
      });
      _coinName = ModalRoute.of(context)!.settings.arguments as String;
      _connectionProvider = Provider.of<ConnectionProvider>(context);
      _walletProvider = Provider.of<WalletProvider>(context);
      _walletNumber = _walletProvider.getWalletNumber(_coinName);

      await _walletProvider.prepareForRescan(_coinName);

      await _connectionProvider!.init(_coinName, scanMode: true);

      _timer = Timer.periodic(const Duration(seconds: 7), (timer) async {
        var dueTime = _latestUpdate + 7;
        if (_connectionState == ConnectionState.waiting) {
          await _connectionProvider!.init(_coinName, scanMode: true);
        } else if (dueTime <= DateTime.now().millisecondsSinceEpoch ~/ 1000 &&
            _scanStarted == true) {
          _timeOutTasks(context);
        }
      });
      if (_backgroundNotificationsAvailable == true) {
        await _fetchAddressesFromBackend();
      }
    } else if (_connectionProvider != null) {
      _connectionState = _connectionProvider!.connectionState;
      if (_connectionState == BackendConnectionState.connected) {
        _latestUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        if (_backgroundNotificationsAvailable == false) {
          await _startScan();
        }
      }
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> _fetchAddressesFromBackend() async {
    var adressesToQuery = <String, int>{};
    await _walletProvider.populateWifMap(
      identifier: _coinName,
      maxValue: _addressScanPointer + _addressChunkSize,
      walletNumber: _walletNumber,
    );

    for (int i = _addressScanPointer;
        i < _addressScanPointer + _addressChunkSize;
        i++) {
      var res = await _walletProvider.getAddressFromDerivationPath(
        identifier: _coinName,
        account: _walletNumber,
        chain: i,
        address: 0,
      );
      adressesToQuery[res!] = 0;
    }

    await _parseMarismaResult(
      await BackgroundSync.getNumberOfUtxosFromMarisma(
        walletName: _coinName,
        addressesToQuery: adressesToQuery,
        fromScan: true,
      ),
    );
    _latestUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  Future<void> _parseMarismaResult(Map<String, int> result) async {
    if (result.isNotEmpty) {
      LoggerWrapper.logInfo(
        'WalletImportScan',
        'parseBackendResult',
        result.toString(),
      );
      //loop through addresses in result
      result.forEach((addr, n) async {
        //backend knows this addr
        if (n > 0) {
          await _walletProvider.addAddressFromScan(
            identifier: _coinName,
            address: addr,
            status: 'hasUtxo',
          );
        }
      });

      //keep searching in next chunk
      setState(() {
        _addressScanPointer += _addressChunkSize;
        _addressChunkSize += 5;
      });
      await _fetchAddressesFromBackend();
    } else {
      //done
      await _startScan();
    }
    _latestUpdate = DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  Future<void> _startScan() async {
    if (_scanStarted == false) {
      LoggerWrapper.logInfo(
        'WalletImportScan',
        'startScan',
        'Scan started - _backgroundNotificationsAvailable $_backgroundNotificationsAvailable',
      );
      //returns master address for hd wallet
      var masterAddr = await _walletProvider.getAddressFromDerivationPath(
        identifier: _coinName,
        account: _walletNumber,
        chain: 0,
        address: 0,
        isMaster: true,
      );

      //subscribe to hd master
      _connectionProvider!.subscribeToScriptHashes(
        _backgroundNotificationsAvailable
            ? await _walletProvider.getWalletScriptHashes(
                _coinName,
              )
            : await _walletProvider.getWalletScriptHashes(
                _coinName,
                masterAddr,
              ),
      );

      setState(() {
        _scanStarted = true;
      });
    }
  }

  void _timeOutTasks(BuildContext context) async {
    //tasks to finish after timeout
    final navigator = Navigator.of(context);
    //sync notification backend
    await BackgroundSync.executeSync(fromScan: true);
    _timer.cancel();
    await navigator.pushReplacementNamed(
      Routes.walletList,
      arguments: {'fromScan': true},
    );
  }
  //TODO rewrite to find wallet accounts and be more verbose
  //TODO test multi wallets without background notifications
}
