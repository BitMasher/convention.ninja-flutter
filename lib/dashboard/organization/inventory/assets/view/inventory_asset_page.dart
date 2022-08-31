import 'package:convention_ninja/dashboard/organization/inventory/assets/view/asset_form.dart';
import 'package:convention_ninja/management/routes/selection_keys.dart';
import 'package:flutter/material.dart';

import '../../../../../management/view/management_scaffold.dart';

class InventoryAssetPage extends StatelessWidget {
  const InventoryAssetPage(
      {super.key, required String organizationId, required String assetId})
      : _organizationId = organizationId,
        _assetId = assetId;
  final String _organizationId;
  final String _assetId;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
      organizationId: _organizationId,
      selectionKey: inventoryAssetsKey,
      child: AssetForm(
        organizationId: _organizationId,
        assetId: _assetId,
      ),
    );
  }
}
