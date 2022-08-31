import 'package:convention_ninja/management/view/management_scaffold.dart';
import 'package:flutter/material.dart';

class OrgDashboardPage extends StatelessWidget {
  const OrgDashboardPage({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
        organizationId: _organizationId, selectionKey: '', child: Text('org dashboard $_organizationId'));
  }
}
