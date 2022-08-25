import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/organization_service.dart';

class DashboardLandingPage extends StatefulWidget {
  const DashboardLandingPage({Key? key}) : super(key: key);

  @override
  State<DashboardLandingPage> createState() => _DashboardLandingPageState();
}

class _DashboardLandingPageState extends State<DashboardLandingPage> {
  late final Future<List<Organization>> _orgs;
  @override
  void initState() {
    super.initState();
    _orgs = OrganizationService.getAll();
    print("init state 2");
  }
  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<Organization>>(
        future: _orgs,
        initialData: const [],
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
                padding: const EdgeInsets.all(8),
                children: <Widget>[
                  for (var value in snapshot.data!)
                    ListTile(
                        leading: const FaIcon(FontAwesomeIcons.solidFolder),
                        title: Text(value.name),
                        onTap: () {
                          Beamer.of(context)
                              .parent
                              ?.beamToNamed('/dashboard/${value.id}');
                        }),
                  ListTile(
                      leading: const FaIcon(FontAwesomeIcons.folderPlus),
                      title: const Text('New Organization'),
                      onTap: () {
                        Beamer.of(context)
                            .parent
                            ?.beamToNamed('/dashboard/new');
                      })
                ]);
          }
          return const SelectableText("loading...");
        },
      ),
    );
  }
}
