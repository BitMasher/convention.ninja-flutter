import 'package:convention_ninja/dashboard/view/organization_list_view.dart';
import 'package:flutter/material.dart';
import '../../management/view/management_scaffold.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ManagementScaffold(
        organizationId: null, selectionKey: '', child: OrganizationListView());
  }
}
