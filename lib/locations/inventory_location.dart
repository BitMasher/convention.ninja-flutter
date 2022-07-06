
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class InventoryLocation extends BeamLocation<BeamState> {
  InventoryLocation(RouteInformation routeInformation) : super(routeInformation);

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
    print(state.uri);
    return [
      BeamPage(child: SelectableText(state.uri.toString()))
    ];
  }

}