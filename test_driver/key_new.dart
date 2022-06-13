import 'dart:io';

import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group(
    'Setup',
    () {
      final elevatedButtonFinder = find.byType('ElevatedButton');
      late FlutterDriver driver;

      Future<FlutterDriver> setupAndGetDriver() async {
        var driver = await FlutterDriver.connect();
        var connected = false;
        while (!connected) {
          try {
            await driver.waitUntilFirstFrameRasterized();
            connected = true;
            // ignore: empty_catches
          } catch (error) {}
        }
        return driver;
      }

      setUpAll(() async {
        useMemoryFileSystemForTesting();
        driver = await setupAndGetDriver();
      });

      tearDownAll(() async {
        restoreFileSystem();
        await driver.close();
      });

      test(
        'create new wallet from scratch',
        () async {
          //creates a brand new peercoin testnet wallet from scratch and check if it connects
          await driver.tap(find.byValueKey('setupLanguageButton'));
          await driver.tap(find.text('English'));
          await driver.tap(find.pageBack());
          await driver.tap(find.text('Create Wallet'));
          await driver.tap(find.text('Export now'));
          await driver.tap(find.text('Continue'));
          await driver.tap(find.text('Continue'));
          await driver.tap(elevatedButtonFinder); //pin pad
          for (var i = 1; i <= 12; i++) {
            await driver.tap(find.text('0'));
          }
          await driver.tap(find.byValueKey('setupApiTickerSwitchKey'));
          await driver.tap(find.byValueKey('setupApiBGSwitchKey'));
          await driver.tap(find.text('Continue'));
          // final pixels = await driver.screenshot();
          // final file = File('shot.png');
          // await file.writeAsBytes(pixels);
          await driver.tap(find.byValueKey('setupLegalConsentKey'));
          await driver.tap(find.text('Finish Setup'));
          await driver.tap(find.pageBack());
          await driver.runUnsynchronized(
            () async {
              expect(
                await driver.getText(find.byValueKey('noActiveWallets')),
                'You have no active wallets',
              );
            },
          );
        },
        timeout: Timeout.none,
      );

      test(
        'tap into new peercoin testnet wallet',
        () async {
          await driver.runUnsynchronized(
            () async {
              await driver.tap(find.byValueKey('newWalletIconButton'));
              await driver.tap(find.text('Peercoin Testnet'));
              await driver.tap(find.text('Peercoin Testnet')); //tap into wallet
              expect(await driver.getText(find.text('connected')), 'connected');
            },
          );
        },
      );
    },
  );
}
