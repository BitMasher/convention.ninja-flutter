import 'package:convention_ninja/dashboard/organization/inventory/manufacturers/view/manufacturer_list_view.dart';
import 'package:flutter/material.dart';

import '../../../../../management/routes/selection_keys.dart';
import '../../../../../management/view/management_scaffold.dart';

class InventoryManufacturersPage extends StatelessWidget {
  const InventoryManufacturersPage({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
        organizationId: _organizationId,
        selectionKey: inventoryManufacturersKey,
        child: ManufacturerListView(organizationId: _organizationId));
  }
}
