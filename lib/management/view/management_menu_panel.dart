import 'package:convention_ninja/management/routes/selection_keys.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ManagementMenuPanel extends StatelessWidget {
  const ManagementMenuPanel(
      {super.key, required String organizationId, required String selectionKey})
      : _organizationId = organizationId,
        _selectionKey = selectionKey;

  final String _organizationId;
  final String _selectionKey;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
        expandedHeaderPadding: EdgeInsets.zero,
        elevation: 0,
        children: [
          _inventoryExpansionPanel(context, _organizationId, _selectionKey)
        ]);
  }
}

ExpansionPanel _inventoryExpansionPanel(
    BuildContext context, String organizationId, String selectionKey) {
  return ExpansionPanel(
      isExpanded: true,
      canTapOnHeader: false,
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          leading: const FaIcon(
            FontAwesomeIcons.warehouse,
            size: 15,
            semanticLabel: 'Asset Management Icon',
          ),
          minLeadingWidth: 0.0,
          title: const Text(
            'Asset Mgmt',
            semanticsLabel: 'Asset Management',
          ),
          onTap: () => context.go('/dashboard/$organizationId/inventory'),
        );
      },
      body: Column(children: [
        ListTile(
            leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.folder,
                  size: 15,
                  semanticLabel: 'Categories Icon',
                )),
            selected: selectionKey == inventoryCategoriesKey,
            minLeadingWidth: 5.0,
            title: const Text(
              'Categories',
              semanticsLabel: 'Categories',
            ),
            onTap: () =>
                context.go('/dashboard/$organizationId/inventory/categories')),
        ListTile(
            leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.industry,
                  size: 15,
                  semanticLabel: 'Manufacturers Icon',
                )),
            selected: selectionKey == inventoryManufacturersKey,
            minLeadingWidth: 5.0,
            title: const Text(
              'Manufacturers',
              semanticsLabel: 'Manufacturers',
            ),
            onTap: () => context
                .go('/dashboard/$organizationId/inventory/manufacturers')),
        ListTile(
            leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.boxesStacked,
                  size: 15,
                  semanticLabel: 'Models Icon',
                )),
            selected: selectionKey == inventoryModelsKey,
            minLeadingWidth: 5.0,
            title: const Text(
              'Models',
              semanticsLabel: 'Models',
            ),
            onTap: () =>
                context.go('/dashboard/$organizationId/inventory/models')),
        ListTile(
            leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.barcode,
                  size: 15,
                  semanticLabel: 'Assets Icon',
                )),
            selected: selectionKey == inventoryAssetsKey,
            minLeadingWidth: 5.0,
            title: const Text(
              'Assets',
              semanticsLabel: 'Assets',
            ),
            onTap: () =>
                context.go('/dashboard/$organizationId/inventory/assets')),
        ListTile(
            leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.truckFast,
                  size: 15,
                  semanticLabel: 'Manifests Icon',
                )),
            selected: selectionKey == inventoryManifestsKey,
            minLeadingWidth: 5.0,
            title: const Text(
              'Manifests',
              semanticsLabel: 'Manifests',
            ),
            onTap: () =>
                context.go('/dashboard/$organizationId/inventory/manifests')),
        ListTile(
            leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.upload,
                  size: 15,
                  semanticLabel: 'Import Icon',
                )),
            selected: selectionKey == inventoryImportKey,
            minLeadingWidth: 5.0,
            title: const Text(
              'Import',
              semanticsLabel: 'Import',
            ),
            onTap: () =>
                context.go('/dashboard/$organizationId/inventory/import')),
      ]));
}
