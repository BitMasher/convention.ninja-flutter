import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AdminMenuPanel extends StatelessWidget {
  const AdminMenuPanel({
    Key? key,
    required GlobalKey<BeamerState> beamKey,
    required this.organizationId,
  })  : _beamKey = beamKey,
        super(key: key);

  final GlobalKey<BeamerState> _beamKey;
  final String organizationId;

  @override
  Widget build(BuildContext context) {
    return ExpansionPanelList(
      expandedHeaderPadding: EdgeInsets.zero,
      elevation: 0,
      children: [
        ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              leading: const FaIcon(
                FontAwesomeIcons.warehouse,
                size: 15,
                semanticLabel: 'Asset Mgmt',
              ),
              minLeadingWidth: 0.0,
              title: const Text(
                'Asset Mgmt',
                semanticsLabel: 'Asset Management',
              ),
              onTap: () => _beamKey.currentState!.routerDelegate
                  .beamToNamed('/dashboard/$organizationId/inventory'),
            );
          },
          body: Column(children: [
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.folder,
                  size: 15,
                  semanticLabel: 'Categories',
                ),
              ),
              selected: true,
              minLeadingWidth: 5.0,
              title: const Text(
                'Categories',
                semanticsLabel: 'Categories',
              ),
              onTap: () => _beamKey.currentState!.routerDelegate.beamToNamed(
                  '/dashboard/$organizationId/inventory/categories'),
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.industry,
                  size: 15,
                  semanticLabel: 'Manufacturers',
                ),
              ),
              minLeadingWidth: 5.0,
              title: const Text(
                'Manufacturers',
                semanticsLabel: 'Manufacturers',
              ),
              onTap: () => Future.delayed(const Duration(milliseconds: 500))
                  .then((value) => _beamKey.currentState?.routerDelegate
                      .beamToNamed(
                          '/dashboard/$organizationId/inventory/manufacturers')),
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.boxesStacked,
                  size: 15,
                  semanticLabel: 'Models',
                ),
              ),
              minLeadingWidth: 5.0,
              title: const Text(
                'Models',
                semanticsLabel: 'Models',
              ),
              onTap: () => Future.delayed(const Duration(milliseconds: 500))
                  .then((value) => _beamKey.currentState?.routerDelegate
                      .beamToNamed(
                          '/dashboard/$organizationId/inventory/models')),
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.barcode,
                  size: 15,
                  semanticLabel: 'Assets',
                ),
              ),
              minLeadingWidth: 5.0,
              title: const Text(
                'Assets',
                semanticsLabel: 'Assets',
              ),
              onTap: () => Future.delayed(const Duration(milliseconds: 500))
                  .then((value) => _beamKey.currentState?.routerDelegate
                      .beamToNamed(
                          '/dashboard/$organizationId/inventory/assets')),
            ),
            ListTile(
              leading: const Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: FaIcon(
                  FontAwesomeIcons.truckFast,
                  size: 15,
                  semanticLabel: 'Manifests',
                ),
              ),
              minLeadingWidth: 5.0,
              title: const Text(
                'Manifests',
                semanticsLabel: 'Manifests',
              ),
              onTap: () => Future.delayed(const Duration(milliseconds: 500))
                  .then((value) => _beamKey.currentState?.routerDelegate
                      .beamToNamed(
                          '/dashboard/$organizationId/inventory/manifests')),
            ),
          ]),
          isExpanded: true,
          canTapOnHeader: true,
        )
      ],
    );
  }
}
