import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Widget _verticalSpacer = SizedBox(height: 8.0);

class DashboardMenuEntry {
  IconData icon;
  String label;
  List<DashboardMenuEntry>? children;
  Function() Function(BuildContext, AdminScaffold)? getOnTap;

  DashboardMenuEntry(
      {required this.icon, required this.label, this.children, this.getOnTap});
}

class AdminScaffold extends StatelessWidget {
  final void Function(String organization) organizationUpdater;
  final String organization;
  final Widget child;

  final List<DashboardMenuEntry> menu = [
    DashboardMenuEntry(
        icon: FontAwesomeIcons.warehouse,
        label: 'Asset Mgmt',
        getOnTap: (BuildContext context, AdminScaffold container) {
          return () {
            Navigator.pushNamed(context, '/dashboard/${container.organization}/inventory');
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
              icon: FontAwesomeIcons.industry, label: 'Manufacturers',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/manufacturers');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.boxesStacked, label: 'Models',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/models');
                };
              }),
          DashboardMenuEntry(icon: FontAwesomeIcons.barcode, label: 'Assets',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/assets');
                };
              }),
          DashboardMenuEntry(
              icon: FontAwesomeIcons.truckFast, label: 'Manifests',
              getOnTap: (BuildContext context, AdminScaffold container) {
                return () {
                  Navigator.pushNamed(context,
                      '/dashboard/${container.organization}/inventory/manifests');
                };
              }),
        ])
  ];

  AdminScaffold({
    Key? key,
    required this.organizationUpdater,
    required this.organization,
    required this.child,
  }) : super(key: key);

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
        onTap: entry.getOnTap != null ? entry.getOnTap!(context, this) : null);
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
          onTap: entry.getOnTap != null ? entry.getOnTap!(context, this) : null,
        );
      },
      body: Column(children: children),
      isExpanded: children.isNotEmpty,
      canTapOnHeader: entry.getOnTap != null,
    );
  }

  List<ExpansionPanel> getMenu(
      BuildContext context, List<DashboardMenuEntry> entries) {
    var ret = <ExpansionPanel>[];
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
          title: Text(organization),
          centerTitle: true,
          actions: [
            PopupMenuButton<String>(
                icon: const FaIcon(FontAwesomeIcons.sitemap),
                onSelected: (String item) {
                  if (item == '__neworg') {
                    Navigator.pushNamed(context, '/dashboard/new');
                  } else {
                    if (item != organization) {
                      organizationUpdater(item);
                      Navigator.pushNamed(context, '/dashboard/$item');
                    }
                  }
                },
                itemBuilder: (BuildContext ctx) =>
                const <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'Test Org',
                    child: Text('Test'),
                  ),
                  PopupMenuItem<String>(
                    value: '__neworg',
                    child: Text('New Organization'),
                  )
                ]),
            IconButton(
                icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
                onPressed: () {
                  FirebaseAuth.instance.signOut();
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
                Center(child: child),
              ],
            ),
          )
        ]));
  }
}