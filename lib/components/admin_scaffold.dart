import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/organization_service.dart';

const Widget _verticalSpacer = SizedBox(height: 8.0);

class DashboardMenuEntry {
  IconData icon;
  String label;
  List<DashboardMenuEntry>? children;
  Function() Function(BuildContext, AdminScaffold)? getOnTap;

  DashboardMenuEntry(
      {required this.icon, required this.label, this.children, this.getOnTap});
}

class AdminScaffold extends StatefulWidget {
  final void Function(String organization) organizationUpdater;
  final String organization;
  final Widget child;

  const AdminScaffold({
    Key? key,
    required this.organizationUpdater,
    required this.organization,
    required this.child,
  }) : super(key: key);

  @override
  State<AdminScaffold> createState() => _AdminScaffoldState();
}

class _AdminScaffoldState extends State<AdminScaffold> {
  final List<DashboardMenuEntry> menu = [
    DashboardMenuEntry(
        icon: FontAwesomeIcons.warehouse,
        label: 'Asset Mgmt',
        getOnTap: (BuildContext context, AdminScaffold container) {
          return () {
            Navigator.pushNamed(
                context, '/dashboard/${container.organization}/inventory');
          };
        },
        children: [
          DashboardMenuEntry(
              icon: FontAwesomeIcons.folder,
              label: 'Categories',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/categories');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.industry,
              label: 'Manufacturers',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/manufacturers');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.boxesStacked,
              label: 'Models',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/models');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.barcode,
              label: 'Assets',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/assets');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.truckFast,
              label: 'Manifests',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/manifests');
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
            entry.getOnTap != null ? entry.getOnTap!(context, widget) : null);
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
              entry.getOnTap != null ? entry.getOnTap!(context, widget) : null,
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
  }

  List<ExpansionPanel> getMenu(
      BuildContext context, List<DashboardMenuEntry> entries) {
    var ret = <ExpansionPanel>[];
    for (var entry in entries) {
      ret.add(menuItem(context, entry, 0));
    }
    return ret;
  }
  Route<dynamic> generateRoute(settings) {
    return MaterialPageRoute(
      builder: (BuildContext ctx) {
        return Scaffold(
          body: Center(child: Text(settings.name))
        );
      },
      settings: RouteSettings(name: settings.name)
    );
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
                  id: widget.organization,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                  name: widget.organization,
                  ownerId: '')
            ],
            builder: (_, snapshot) {
              for (var value in snapshot.requireData) {
                if (value.id == widget.organization) {
                  return Text(value.name);
                }
              }
              return Text(widget.organization);
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
                          Navigator.pushNamed(context, '/dashboard/new');
                        } else {
                          if (item != widget.organization) {
                            widget.organizationUpdater(item);
                            Navigator.pushNamed(context, '/dashboard/$item');
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
                      () => Navigator.pushNamed(context, '/login'));
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
                  child: Navigator(
                    onGenerateInitialRoutes: (NavigatorState _, String initialRoute) {
                      return [generateRoute(RouteSettings(name: initialRoute))];
                    },
                    onGenerateRoute: generateRoute,
                  ),
                ),
                Center(child: widget.child),
              ],
            ),
          )
        ]));
  }
}
