import 'package:bitcoin_flutter/bitcoin_flutter.dart';
import 'package:peercoin/models/coin.dart';

class AvailableCoins {
  final Map<String, Coin> _availableCoinList = {
    'peercoin': Coin(
      name: 'peercoin',
      displayName: 'Peercoin',
      uriCode: 'peercoin',
      letterCode: 'PPC',
      iconPath: 'assets/icon/ppc-icon-48.png',
      iconPathTransparent: 'assets/icon/ppc-icon-white-48.png',
      networkType: NetworkType(
        messagePrefix: '\x18Peercoin Signed Message:\n',
        bech32: 'pc',
        bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
        pubKeyHash: 0x37,
        scriptHash: 0x75,
        wif: 0xb7,
      ),
      fractions: 6,
      minimumTxValue: 10000,
      feePerKb: 0.01,
      explorerTxDetailUrl: 'https://blockbook.peercoin.net/tx/',
      genesisHash:
          '0000000032fe677166d54963b62a4677d8957e87c508eaa4fd7eb1c880cd27e3',
      txVersion: 1, //TODO v0.11 main net release: change to 3
    ),
    'peercoinTestnet': Coin(
      name: 'peercoinTestnet',
      displayName: 'Peercoin Testnet',
      uriCode: 'peercoin',
      letterCode: 'tPPC',
      iconPath: 'assets/icon/ppc-icon-48.png',
      iconPathTransparent: 'assets/icon/ppc-icon-white-48.png',
      networkType: NetworkType(
        messagePrefix: '\x18Peercoin Signed Message:\n',
        bech32: 'tpc',
        bip32: Bip32Type(public: 0x043587cf, private: 0x04358394),
        pubKeyHash: 0x6f,
        scriptHash: 0xc4,
        wif: 0xef,
      ),
      fractions: 6,
      minimumTxValue: 10000,
      feePerKb: 0.01,
      explorerTxDetailUrl: 'https://tblockbook.peercoin.net/tx/',
      genesisHash:
          '00000001f757bb737f6596503e17cd17b0658ce630cc727c0cca81aec47c9f06',
      txVersion: 1, //TODO v0.11 main net release: change to 3
    ),
  };

  Map<String, Coin> get availableCoins {
    return _availableCoinList;
  }

  Coin getSpecificCoin(identifier) {
    return _availableCoinList[identifier]!;
  }
}
