import 'package:beamer/beamer.dart';
import 'package:convention_ninja/locations/dashboard_location.dart';
import 'package:convention_ninja/locations/inventory_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/organization_service.dart';
import 'admin_left_panel.dart';
import 'async_organization_dropdown.dart';
import 'async_organization_title.dart';

class AdminScaffold extends StatefulWidget {
  AdminScaffold({Key? key, required this.organizationId}) : super(key: key);

  final String organizationId;

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final GlobalKey<BeamerState> _beamKey = GlobalKey<BeamerState>();

  late final Future<List<Organization>> _orgs;

  @override
  void initState() {
    super.initState();
    print("init state");
    _orgs = OrganizationService.getAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 10,
          title: AsyncOrganizationTitle(
              organizations: _orgs, organizationId: widget.organizationId),
          centerTitle: true,
          actions: [
            AsyncOrganizationDropdown(
                organizations: _orgs, organizationId: widget.organizationId),
            IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                onPressed: () {
                  FirebaseAuth.instance.signOut().whenComplete(() {
                    context.beamToNamed('/login');
                  });
                })
          ],
        ),
        body: Row(children: [
          if (widget.organizationId.isNotEmpty && widget.organizationId != "new")
            AdminLeftPanel(organizationId: widget.organizationId, beamKey: _beamKey),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Beamer(
                    key: _beamKey,
                    routerDelegate: BeamerDelegate(
                      transitionDelegate: const NoAnimationTransitionDelegate(),
                      // initialPath: Beamer.of(context).configuration.location ?? '/',
                      updateParent: false,
                      locationBuilder: (routeInformation, _) {
                        if (routeInformation.location!.contains("/inventory")) {
                          return InventoryLocation(routeInformation);
                        } else if (routeInformation.location == "/dashboard/new") {
                          return DashboardLocation(routeInformation);
                        } else if (routeInformation.location == "/dashboard") {
                          return DashboardLocation(routeInformation);
                        } else {
                          return InventoryLocation(routeInformation);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          )
        ]));
  }
}
