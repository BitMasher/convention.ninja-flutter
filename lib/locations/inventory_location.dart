import 'package:beamer/beamer.dart';
import 'package:convention_ninja/pages/inventory_landing_page.dart';
import 'package:convention_ninja/pages/inventory_manifest_modify.dart';
import 'package:convention_ninja/pages/inventory_manifests_page.dart';
import 'package:convention_ninja/pages/inventory_manufacturers_page.dart';
import 'package:convention_ninja/pages/inventory_models_page.dart';
import 'package:flutter/material.dart';

import '../pages/inventory_asset_modify.dart';
import '../pages/inventory_assets_page.dart';
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
        '/dashboard/:orgId/inventory/assets/new',
        '/dashboard/:orgId/inventory/assets/:assetId',
        '/dashboard/:orgId/inventory/manifests',
        '/dashboard/:orgId/inventory/manifests/:manifestId'
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
            child:
                InventoryCategoriesPage(orgId: state.pathParameters['orgId']!))
      ];
    } else if (state.uri.path.endsWith('/manufacturers')) {
      return [
        BeamPage(
            key: ValueKey(
                'inventory-manufacturers-${state.pathParameters['orgId']}'),
            title: 'Asset Manufacturers',
            child: InventoryManufacturersPage(
                orgId: state.pathParameters['orgId']!))
      ];
    } else if (state.uri.path.endsWith('/models')) {
      return [
        BeamPage(
            key: ValueKey('inventory-models-${state.pathParameters['orgId']}'),
            title: 'Asset Models',
            child: InventoryModelsPage(orgId: state.pathParameters['orgId']!))
      ];
    } else if (state.uri.path.endsWith('/assets')) {
      return [
        BeamPage(
            key: ValueKey('inventory-assets-${state.pathParameters['orgId']}'),
            title: 'Assets',
            child: InventoryAssetsPage(orgId: state.pathParameters['orgId']!))
      ];
    } else if (state.uri.path.endsWith('/assets/new')) {
      return [
        BeamPage(
            key: ValueKey(
                'inventory-assets-new-${state.pathParameters['orgId']}'),
            title: 'New Asset',
            child: InventoryAssetModify(
                orgId: state.pathParameters['orgId']!, assetId: null))
      ];
    } else if (state.uri.path.contains('/assets/')) {
      return [
        BeamPage(
            key: ValueKey(
                'inventory-assets-update-${state.pathParameters['assetId']}-${state.pathParameters['orgId']}'),
            title: 'Modify Asset',
            child: InventoryAssetModify(
                orgId: state.pathParameters['orgId']!,
                assetId: state.pathParameters['assetId']!))
      ];
    } else if (state.uri.path.endsWith('/manifests')) {
      return [
        BeamPage(
            key: ValueKey(
                'inventory-manifests-${state.pathParameters['orgId']}'),
            title: 'Manifests',
            child:
                InventoryManifestsPage(orgId: state.pathParameters['orgId']!))
      ];
    } else if (state.uri.path.contains('/manifests/')) {
      return [
        BeamPage(
            key: ValueKey(
                'inventory-manifests-${state.pathParameters['manifestId']}-${state.pathParameters['orgId']}'),
            title: 'Modify Manifest',
            child: InventoryManifestModify(
                orgId: state.pathParameters['orgId']!,
                manifestId: state.pathParameters['manifestId']!))
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
