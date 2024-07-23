import 'package:flutter/material.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_pubkey.dart';

class FrostGroupSetupLanding extends StatefulWidget {
  const FrostGroupSetupLanding({super.key});

  @override
  State<FrostGroupSetupLanding> createState() => _FrostGroupSetupLandingState();
}

enum FrostSetupStep { group, pubkey }

class _FrostGroupSetupLandingState extends State<FrostGroupSetupLanding> {
  FrostSetupStep _step = FrostSetupStep.group;
  final _groupIdKey = GlobalKey<FormFieldState>();
  final _groupIdController = TextEditingController();
  final _serverKey = GlobalKey<FormFieldState>();
  final _serverController = TextEditingController();

  Future<void> _save() async {
    // TODO Implement save
    // TODO try calling server url to see if it is valid

    setState(() {
      _step = FrostSetupStep.pubkey;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_step == FrostSetupStep.pubkey) {
      return const FrostGroupSetupPubkey();
    }
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              child: PeerContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      AppLocalizations.instance
                          .translate('frost_setup_landing_title'),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('frost_setup_landing_description'),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Form(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            key: _groupIdKey,
                            autocorrect: false,
                            controller: _groupIdController,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.group),
                              labelText: AppLocalizations.instance.translate(
                                  'frost_setup_landing_group_id_input'),
                            ),
                          ),
                          Text(
                            AppLocalizations.instance.translate(
                              'frost_setup_landing_group_id_input_hint',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            textInputAction: TextInputAction.done,
                            key: _serverKey,
                            autocorrect: false,
                            controller: _serverController,
                            decoration: InputDecoration(
                              icon: const Icon(Icons.outbond),
                              labelText: AppLocalizations.instance.translate(
                                'frost_setup_landing_server_url_input',
                              ),
                            ),
                          ),
                          Text(
                            AppLocalizations.instance.translate(
                              'frost_setup_landing_server_url_input_hint',
                            ),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          PeerButton(
                            text: AppLocalizations.instance
                                .translate('frost_setup_landing_cta'),
                            action: () => _save(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// TODO On success you will be taken to the next page where the public keys of the participants will be shown
// TODO group name can be changed later through context menu to avoid confusion between group name and group id

// 3. If the configuration is not complete, there will be a configuration page that displays a public key for the participant for them to share.
// 4. On this page a list of other participants is shown with: 1. Name. 2. Identifier and 3. Public key. This list will have a "+" or "Add" button to add a new participant with the ability to edit or remove other participant details.
// 5. There will also be an ID field for the group that can be any string. Should we limit to alphanumeric and possibly underscores?
// 6. After details are updated a new potential GroupConfig will be created and the fingerprint will be shown so that it can be compared against other participant's config to ensure it is the same.
// 7. If a user navigates away from the screen, the current configuration settings will be saved in an incomplete state.
// 7. A "Finish" button will move the state to a completed configuration. An ability to download the configuration details for use on a coordination server will be needed.
// 8. Perhaps the next page should have the options: 1. Connect to server (which will present the full DKG and signing options later). 2. Download configuration (for use on a server). 3. Modify configuration (if configuration is later changed, it goes back to the previous screen).