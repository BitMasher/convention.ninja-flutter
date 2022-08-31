import 'package:flutter/material.dart';

import 'management_menu_panel.dart';

class ManagementLeftPanel extends StatelessWidget {
  const ManagementLeftPanel(
      {super.key, required String organizationId, required String selectionKey})
      : _organizationId = organizationId,
        _selectionKey = selectionKey;
  final String _organizationId;
  final String _selectionKey;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 0.0,
      color: Theme.of(context).colorScheme.surface,
      child: Column(children: [
        const SizedBox(height: 8.0),
        Expanded(
            child: Align(
                alignment: const Alignment(0, -1),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      constraints:
                          const BoxConstraints(minWidth: 150, maxWidth: 250),
                      child: ManagementMenuPanel(
                        organizationId: _organizationId,
                        selectionKey: _selectionKey,
                      )),
                ]))),
      ]),
    );
  }
}
