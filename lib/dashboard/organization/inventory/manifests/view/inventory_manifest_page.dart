import 'package:convention_ninja/management/routes/selection_keys.dart';
import 'package:convention_ninja/management/view/management_scaffold.dart';
import 'package:flutter/material.dart';

import 'manifest_form.dart';

class InventoryManifestPage extends StatelessWidget {
  const InventoryManifestPage(
      {super.key, required String organizationId, required String manifestId})
      : _organizationId = organizationId,
        _manifestId = manifestId;
  final String _organizationId;
  final String _manifestId;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
      organizationId: _organizationId,
        selectionKey: inventoryManifestsKey,
        child: ManifestForm(organizationId: _organizationId, manifestId: _manifestId,));
  }
}
