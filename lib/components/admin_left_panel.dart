import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'admin_menu_panel.dart';

const Widget _verticalSpacer = SizedBox(height: 8.0);

class AdminLeftPanel extends StatelessWidget {
  const AdminLeftPanel({
    Key? key,
    required this.organizationId,
    required GlobalKey<BeamerState> beamKey,
  })  : _beamKey = beamKey,
        super(key: key);

  final String organizationId;
  final GlobalKey<BeamerState> _beamKey;

  @override
  Widget build(BuildContext context) {
    return Semantics(
        explicitChildNodes: true,
        child: Material(
            elevation: 0.0,
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                _verticalSpacer,
                Expanded(
                  child: Align(
                      alignment: const Alignment(0, -1),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(
                                minWidth: 150, maxWidth: 250),
                            child: AdminMenuPanel(
                                    beamKey: _beamKey,
                                    organizationId: organizationId),
                          )
                        ],
                      )),
                )
              ],
            )));
  }
}
