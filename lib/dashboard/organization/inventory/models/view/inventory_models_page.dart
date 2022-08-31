import 'package:convention_ninja/management/routes/selection_keys.dart';
import 'package:convention_ninja/management/view/management_scaffold.dart';
import 'package:flutter/material.dart';

import 'model_list_view.dart';

class InventoryModelsPage extends StatelessWidget {
  const InventoryModelsPage({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
        organizationId: _organizationId,
        selectionKey: inventoryModelsKey,
        child: ModelListView(organizationId: _organizationId));
  }
}
