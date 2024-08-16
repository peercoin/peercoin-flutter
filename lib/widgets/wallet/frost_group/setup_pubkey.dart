import 'package:coinlib_flutter/coinlib_flutter.dart';
import 'package:flutter/material.dart';
import 'package:frost_noosphere/frost_noosphere.dart';
import 'package:peercoin/models/hive/frost_group.dart';
import 'package:peercoin/tools/app_localizations.dart';
import 'package:peercoin/tools/app_routes.dart';
import 'package:peercoin/tools/logger_wrapper.dart';
import 'package:peercoin/widgets/buttons.dart';
import 'package:peercoin/widgets/service_container.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_landing.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_pubkey_finger_print_bottom_sheet.dart';
import 'package:peercoin/widgets/wallet/frost_group/setup_pubkey_remove_participant_bottom_sheet.dart';

class FrostGroupSetupPubkey extends StatefulWidget {
  final Function changeStep;
  final FrostGroup frostGroup;
  const FrostGroupSetupPubkey({
    required this.changeStep,
    required this.frostGroup,
    super.key,
  });

  @override
  State<FrostGroupSetupPubkey> createState() => _FrostGroupSetupPubkeyState();
}

class _FrostGroupSetupPubkeyState extends State<FrostGroupSetupPubkey> {
  bool _initial = true;
  final Map<Identifier, ECPublicKey> _participants = {};

  @override
  void didChangeDependencies() {
    if (_initial) {
      if (widget.frostGroup.clientConfig != null) {
        _participants
            .addAll(widget.frostGroup.clientConfig!.group.participants);
      }
      setState(() {
        _initial = false;
      });
    }
    super.didChangeDependencies();
  }

  void _triggerRemoveParticipantBottomSheet(
    String participantName,
    String participantPubKey,
  ) async {
    LoggerWrapper.logInfo(
      'FrostGroupSetupPubkey',
      '_triggerRemoveParticipantBottomSheet',
      'participant $participantName delete bottom sheet opened',
    );

    // show bottom sheet
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SetupPubkeyRemoveParticipantBottomSheet(
          participantName: participantName,
          action: () => _removeParticipant(participantPubKey),
        );
      },
      context: context,
    );
  }

  void _addParticipant() async {
    final res = await Navigator.of(context).pushNamed(
      Routes.frostWalletAddParticipant,
      arguments: {
        'frostGroup': widget.frostGroup,
      },
    );
    if (res == true) {
      LoggerWrapper.logInfo(
        'FrostGroupSetupPubkey',
        '_addParticipant',
        'participant added',
      );
      setState(() {
        _participants.clear();
        _participants
            .addAll(widget.frostGroup.clientConfig!.group.participants);
      });
    }
  }

  void _removeParticipant(String participantPubKey) {
    Navigator.of(context).pop();

    // remove participant from group
    widget.frostGroup.clientConfig!.group.participants
        .removeWhere((key, value) => value.hex == participantPubKey);

    setState(() {
      // remove copy of participant from local state
      _participants.removeWhere((key, value) => value.hex == participantPubKey);
    });
    LoggerWrapper.logInfo(
      'FrostGroupSetupPubkey',
      '_removeParticipant',
      'participant removed',
    );
  }

  void _completeFrostGroup() {
    // save group
    widget.frostGroup.isCompleted = true;
    Navigator.of(context).pop();
    // change step
  }

  void _showFingerprint() async {
    if (widget.frostGroup.clientConfig == null) {
      return;
    }
    final fingerPrint =
        bytesToHex(widget.frostGroup.clientConfig!.group.fingerprint);
    LoggerWrapper.logInfo(
      'FrostGroupSetupPubkey',
      '_showFingerprint',
      fingerPrint,
    );

    // show bottom sheet
    await showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      isDismissible: false,
      enableDrag: false,
      builder: (BuildContext context) {
        return SetupPubkeyFingerPrintBottomSheet(
          fingerPrint: fingerPrint,
          action: () => _completeFrostGroup(),
        );
      },
      context: context,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Align(
              child: PeerContainer(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () {
                            widget.changeStep(FrostSetupStep.group);
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios,
                          ),
                        ),
                        Text(
                          AppLocalizations.instance
                              .translate('frost_setup_group_title'),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('frost_setup_group_description'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      AppLocalizations.instance
                          .translate('frost_setup_group_hint'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Column(
                      children: _participants.entries.map((entry) {
                        String participantName = widget.frostGroup
                                .participantNames[entry.key.toString()] ??
                            '';
                        String ecPubkey = entry.value.hex;
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          margin: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                          child: ListTile(
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              onPressed: () =>
                                  _triggerRemoveParticipantBottomSheet(
                                participantName,
                                ecPubkey,
                              ),
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            tileColor: Theme.of(context).colorScheme.primary,
                            title: Text(
                              participantName,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            subtitle: Text(
                              ecPubkey,
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'frost_setup_group_member_add',
                      ),
                      action: () => _addParticipant(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    PeerButton(
                      text: AppLocalizations.instance.translate(
                        'frost_setup_group_cta',
                      ),
                      action: () => _showFingerprint(),
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
// 6. After details are updated a new potential GroupConfig will be created and the fingerprint will be shown so that it can be compared against other participant's config to ensure it is the same.
// 7. A "Finish" button will move the state to a completed configuration. An ability to download the configuration details for use on a coordination server will be needed.
// 8. Perhaps the next page should have the options: 1. Connect to server (which will present the full DKG and signing options later). 2. Download configuration (for use on a server). 3. Modify configuration (if configuration is later changed, it goes back to the previous screen).
