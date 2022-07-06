
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/organization_service.dart';

class DashboardLandingPage extends StatelessWidget {
  const DashboardLandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var organizations = OrganizationService.getAll();
    return Center(
      child: FutureBuilder<List<Organization>>(
        future: organizations,
        initialData: const [],
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.done) {
            return ListView(
              padding: const EdgeInsets.all(8),
              children: <Widget>[
                for (var value in snapshot.data!)
                  ListTile(
                    leading: const FaIcon(FontAwesomeIcons.solidFolder),
                    title: Text(value.name),
                    onTap: () {
                      Beamer.of(context).parent?.beamToNamed('/dashboard/${value.id}');
                    }
                  )
              ]
            );
          }
          return const SelectableText("loading...");
        },
      ),
    );
  }

}
