import 'package:convention_ninja/management/routes/selection_keys.dart';
import 'package:flutter/material.dart';

import '../../../../../management/view/management_scaffold.dart';
import 'asset_list_view.dart';

class InventoryAssetsPage extends StatelessWidget {
  const InventoryAssetsPage({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
      organizationId: _organizationId,
      selectionKey: inventoryAssetsKey,
      child: AssetListView(organizationId: _organizationId)
    );
  }
}
