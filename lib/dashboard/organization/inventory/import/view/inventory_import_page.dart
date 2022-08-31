import 'package:flutter/material.dart';

class InventoryImportPage extends StatelessWidget {
  const InventoryImportPage({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  Widget build(BuildContext context) {
    return Text('inventory import page $_organizationId');
  }
}
