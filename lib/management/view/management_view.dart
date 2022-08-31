import 'package:flutter/material.dart';

import 'management_left_panel.dart';

class ManagementView extends StatelessWidget {
  const ManagementView(
      {super.key,
      required String organizationId,
      required String selectionKey,
      required Widget child})
      : _organizationId = organizationId,
        _selectionKey = selectionKey,
        _child = child;
  final String _organizationId;
  final String _selectionKey;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ManagementLeftPanel(
          organizationId: _organizationId,
          selectionKey: _selectionKey,
        ),
        Expanded(
            child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(child: _child),
          ],
        )),
      ],
    );
  }
}
