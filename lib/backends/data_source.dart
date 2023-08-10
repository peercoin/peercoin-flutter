import 'dart:async';

import '../providers/connection.dart';

abstract class DataSource {
  BackendConnectionState connectionState = BackendConnectionState.waiting;
  Map<String, List?> paperWalletUtxos = {};
  List openReplies = [];
  Map addresses = {};
  int latestBlock = 0;

  Future<bool> init(
    walletName, {
    bool scanMode = false,
    bool requestedFromWalletHome = false,
    bool fromConnectivityChangeOrLifeCycle = false,
  }) async {
    throw UnimplementedError();
  }

  Future<void> closeConnection([bool intentional = true]) async {}

  void subscribeToScriptHashes(Map scriptHashes) {}

  void requestPaperWalletUtxos(String hashId, String address) {}
  void broadcastTransaction(String txHash, String txId) {}
  void requestTxUpdate(String txId) {}

  Stream listenerNotifierStream() {
    throw UnimplementedError();
  }

  void notifyListeners() {}
}
