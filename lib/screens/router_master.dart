import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../tools/app_routes.dart';
import 'auth_jail.dart';

enum RouteTypes { requiresSetupFinished, requiresArguments, setupOnly }

class RouterMaster extends StatefulWidget {
  final Widget widget;
  final RouteTypes routeType;

  const RouterMaster({required this.widget, required this.routeType});

  @override
  State<RouterMaster> createState() => _RouterMasterState();
}

class _RouterMasterState extends State<RouterMaster> {
  bool _initial = true;
  Widget? widgetToRender;

  @override
  void didChangeDependencies() async {
    if (_initial) {
      var prefs = await SharedPreferences.getInstance();
      var setupFinished = prefs.getBool('setupFinished') ?? false;

      if (widget.routeType == RouteTypes.setupOnly && setupFinished) {
        //setup is finished and setupOnly screen has been called
        Future.delayed(
          Duration(seconds: 0),
          () => Navigator.of(context).pushReplacementNamed(Routes.WalletList),
        );
      } else if (!setupFinished &&
          widget.routeType == RouteTypes.requiresSetupFinished) {
        Future.delayed(
          Duration(seconds: 0),
          () => Navigator.of(context).pushReplacementNamed('/'),
        );
      } else if (!setupFinished && widget.routeType == RouteTypes.setupOnly) {
        widgetToRender = widget.widget;
        //TODO don't allow unordered access to setup widgets if setup is not finished
      } else if (widget.routeType == RouteTypes.requiresArguments &&
          ModalRoute.of(context)!.settings.arguments == null) {
        Future.delayed(
          Duration(seconds: 0),
          () => Navigator.of(context).pushReplacementNamed('/'),
        );
      } else {
        widgetToRender = widget.widget;
      }

      final _secureStorage = const FlutterSecureStorage();
      var failedAuths =
          int.parse(await _secureStorage.read(key: 'failedAuths') ?? '0');

      if (failedAuths > 0) {
        widgetToRender = AuthJailScreen();
      }

      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return widgetToRender ?? Container();
  }
}
