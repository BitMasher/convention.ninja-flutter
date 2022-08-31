import 'package:flutter/material.dart';

import '../../../../management/view/management_scaffold.dart';

class InventoryDashboardPage extends StatelessWidget {
  const InventoryDashboardPage({super.key, required String organizationId}) : _organizationId = organizationId;
  final String _organizationId;
  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
        organizationId: _organizationId, selectionKey: '', child: Text('inventory dashboard page $_organizationId'));
  }
}