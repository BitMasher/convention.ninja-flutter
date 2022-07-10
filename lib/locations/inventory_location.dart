import 'package:beamer/beamer.dart';
import 'package:convention_ninja/pages/inventory_landing_page.dart';
import 'package:flutter/material.dart';

import '../pages/inventory_categories_page.dart';

class InventoryLocation extends BeamLocation<BeamState> {
  InventoryLocation(RouteInformation routeInformation)
      : super(routeInformation);

  @override
  List<Pattern> get pathPatterns => [
        '/dashboard/:orgId/inventory',
        '/dashboard/:orgId/inventory/categories',
        '/dashboard/:orgId/inventory/manufacturers',
        '/dashboard/:orgId/inventory/models',
        '/dashboard/:orgId/inventory/assets',
        '/dashboard/:orgId/inventory/manifests',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    if (state.uri.path.endsWith('/inventory')) {
      return [
        BeamPage(
            key: ValueKey('inventory-landing-${state.pathParameters['orgId']}'),
            title: 'Asset Management',
            child: const InventoryLandingPage())
      ];
    } else if (state.uri.path.endsWith('/categories')) {
      return [
        BeamPage(
            key: ValueKey(
                'inventory-categories-${state.pathParameters['orgId']}'),
            title: 'Asset Categories',
            child: InventoryCategoriesPage(orgId: state.pathParameters['orgId']!))
      ];
    } else {
      return [
        const BeamPage(
            key: ValueKey('inventory-404'),
            title: 'Asset 404',
            child: SelectableText('asset 404'))
      ];
    }
  }
}
