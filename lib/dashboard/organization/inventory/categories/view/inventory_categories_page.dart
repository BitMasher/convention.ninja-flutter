import 'package:convention_ninja/dashboard/organization/inventory/categories/view/category_list_view.dart';
import 'package:convention_ninja/management/routes/selection_keys.dart';
import 'package:flutter/material.dart';

import '../../../../../management/view/management_scaffold.dart';

class InventoryCategoriesPage extends StatelessWidget {
  const InventoryCategoriesPage({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
        organizationId: _organizationId,
        selectionKey: inventoryCategoriesKey,
        child: CategoryListView(organizationId: _organizationId));
  }
}
