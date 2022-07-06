import 'package:beamer/beamer.dart';
import 'package:convention_ninja/locations/dashboard_location.dart';
import 'package:convention_ninja/locations/inventory_location.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/organization_service.dart';

const Widget _verticalSpacer = SizedBox(height: 8.0);

class DashboardMenuEntry {
  IconData icon;
  String label;
  List<DashboardMenuEntry>? children;
  Function() Function(BuildContext, GlobalKey<BeamerState>, String)? getOnTap;

  DashboardMenuEntry(
      {required this.icon, required this.label, this.children, this.getOnTap});
}

class AdminScaffold extends StatefulWidget {
  AdminScaffold({Key? key, required this.organizationId}) : super(key: key);

  final String organizationId;

  organizationUpdater(String org) {}
  final Widget child = const Text("omg child");
  final GlobalKey<BeamerState> beamKey = GlobalKey<BeamerState>();
  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  List<DashboardMenuEntry> menu = [];

  void _setStateListener() {
    print("asdfasdf");
    setState(() {});
  }

  List<DashboardMenuEntry> createMenu() => [
    DashboardMenuEntry(
        icon: FontAwesomeIcons.warehouse,
        label: 'Asset Mgmt',
        getOnTap: (BuildContext context, GlobalKey<BeamerState> beamKey, String organizationId) {
          return () {
            beamKey.currentState?.routerDelegate.beamToNamed('/dashboard/$organizationId/inventory');
          };
        },
        children: [
          DashboardMenuEntry(
              icon: FontAwesomeIcons.folder,
              label: 'Categories',
              getOnTap: (BuildContext context, GlobalKey<BeamerState> beamKey, String organizationId) {
                return () {
                  beamKey.currentContext?.beamToNamed('/dashboard/$organizationId/inventory/categories');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.industry,
              label: 'Manufacturers',
              getOnTap: (BuildContext context, GlobalKey<BeamerState> beamKey, String organizationId) {
                return () {
                  beamKey.currentState?.routerDelegate.beamToNamed('/dashboard/$organizationId/inventory/manufacturers');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.boxesStacked,
              label: 'Models',
              getOnTap: (BuildContext context, GlobalKey<BeamerState> beamKey, String organizationId) {
                return () {
                  beamKey.currentState?.routerDelegate.beamToNamed('/dashboard/$organizationId/inventory/models');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.barcode,
              label: 'Assets',
              getOnTap: (BuildContext context, GlobalKey<BeamerState> beamKey, String organizationId) {
                return () {
                  beamKey.currentState?.routerDelegate.beamToNamed('/dashboard/$organizationId/inventory/assets');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.truckFast,
              label: 'Manifests',
              getOnTap: (BuildContext context, GlobalKey<BeamerState> beamKey, String organizationId) {
                return () {
                  beamKey.currentState?.routerDelegate.beamToNamed('/dashboard/$organizationId/inventory/manifests');
                };
              }),
        ])
  ];

  Widget menuEntry(BuildContext context, DashboardMenuEntry entry, int depth) {
    assert(entry.children == null);
    return ListTile(
        leading: Padding(
            padding: EdgeInsets.only(left: 15.0 * depth),
            child: FaIcon(entry.icon, size: 15)),
        minLeadingWidth: 5.0 * depth,
        title: Text(
          entry.label,
          semanticsLabel: entry.label,
        ),
        onTap:
            entry.getOnTap != null ? entry.getOnTap!(context, widget.beamKey, widget.organizationId) : null);
  }

  ExpansionPanel menuItem(
      BuildContext context, DashboardMenuEntry entry, int depth) {
    var children = <Widget>[];
    if (entry.children != null) {
      for (var child in entry.children ?? []) {
        children.add(menuEntry(context, child, depth + 1));
      }
    }
    return ExpansionPanel(
      headerBuilder: (BuildContext context, bool isExpanded) {
        return ListTile(
          leading: FaIcon(
            entry.icon,
            size: 15,
            semanticLabel: entry.label,
          ),
          minLeadingWidth: 5.0 * depth,
          title: Text(
            entry.label,
            semanticsLabel: entry.label,
          ),
          onTap:
              entry.getOnTap != null ? entry.getOnTap!(context, widget.beamKey, widget.organizationId) : null,
        );
      },
      body: Column(children: children),
      isExpanded: children.isNotEmpty,
      canTapOnHeader: entry.getOnTap != null,
    );
  }

  late Future<List<Organization>> _organizations;

  @override
  void initState() {
    super.initState();
    _organizations = OrganizationService.getAll();
    menu = createMenu();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      widget.beamKey.currentState?.routerDelegate
          .addListener(_setStateListener);
    });
  }
  @override
  void dispose() {
    widget.beamKey.currentState?.routerDelegate
        .removeListener(_setStateListener);
    super.dispose();
  }

  List<ExpansionPanel> getMenu(
      BuildContext context, List<DashboardMenuEntry> entries) {
    var ret = <ExpansionPanel>[];
    if(widget.organizationId == "" || widget.organizationId == "new") {
      return ret;
    }
    for (var entry in entries) {
      ret.add(menuItem(context, entry, 0));
    }
    return ret;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          elevation: 10,
          title: FutureBuilder<List<Organization>>(
            future: _organizations,
            initialData: [
              Organization(
                  id: widget.organizationId,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  name: widget.organizationId,
                  ownerId: '')
            ],
            builder: (_, snapshot) {
              for (var value in snapshot.requireData) {
                if (value.id == widget.organizationId) {
                  return Text(value.name);
                }
              }
              if(widget.organizationId == "new") {
                return const Text("New Organization");
              }
              return Text(widget.organizationId);
            },
          ),
          centerTitle: true,
          actions: [
            FutureBuilder<List<Organization>>(
                future: _organizations,
                builder: (_, snapshot) {
                  var orgs = <Organization>[];
                  if (snapshot.hasData) {
                    orgs = snapshot.requireData;
                  }
                  return PopupMenuButton<String>(
                      icon: const FaIcon(FontAwesomeIcons.sitemap),
                      onSelected: (String item) {
                        if (item == '__neworg') {
                          Future.delayed(const Duration(milliseconds: 500)).then((value) => Beamer.of(context).beamToNamed('/dashboard/new'));
                        } else {
                          if (item != widget.organizationId) {
                            Future.delayed(const Duration(milliseconds: 500)).then((value) => Beamer.of(context).beamToNamed('/dashboard/$item'));
                          }
                        }
                      },
                      itemBuilder: (BuildContext ctx) =>
                          <PopupMenuEntry<String>>[
                            ...orgs.map((e) => PopupMenuItem<String>(
                                  value: e.id,
                                  child: Text(e.name),
                                )),
                            const PopupMenuItem<String>(
                              value: '__neworg',
                              child: Text('New Organization'),
                            )
                          ]);
                }),
            IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                onPressed: () {
                  FirebaseAuth.instance.signOut().whenComplete(
                      () {context.beamToNamed('/login');});
                })
          ],
        ),
        body: Row(children: [
          Semantics(
              explicitChildNodes: true,
              child: Material(
                  elevation: 0.0,
                  color: Theme.of(context).colorScheme.surface,
                  child: Column(
                    children: [
                      _verticalSpacer,
                      Expanded(
                        child: Align(
                            alignment: const Alignment(0, -1),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  constraints: const BoxConstraints(
                                      minWidth: 150, maxWidth: 250),
                                  child: ExpansionPanelList(
                                    expandedHeaderPadding: EdgeInsets.zero,
                                    elevation: 0,
                                    children: getMenu(context, menu),
                                  ),
                                )
                              ],
                            )),
                      )
                    ],
                  ))),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Flexible(
                  child: Beamer(
                    key: widget.beamKey,
                    routerDelegate: BeamerDelegate(
                      transitionDelegate: const NoAnimationTransitionDelegate(),
                      locationBuilder: (routeInformation, _) {
                        if(routeInformation.location!.contains("/inventory")) {
                          return InventoryLocation(routeInformation);
                        } else if(routeInformation.location!.contains("/dashboard/new")) {
                          return DashboardLocation(routeInformation);
                        } else if(routeInformation.location == "/dashboard") {
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
