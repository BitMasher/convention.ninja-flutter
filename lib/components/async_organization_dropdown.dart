import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../services/organization_service.dart';

class AsyncOrganizationDropdown extends StatelessWidget {
  const AsyncOrganizationDropdown({
    Key? key,
    required Future<List<Organization>> organizations,
    required this.organizationId,
  })  : _organizations = organizations,
        super(key: key);

  final Future<List<Organization>> _organizations;
  final String organizationId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Organization>>(
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
                  Future.delayed(const Duration(milliseconds: 500)).then(
                      (value) =>
                          Beamer.of(context).beamToNamed('/dashboard/new'));
                } else {
                  if (item != organizationId) {
                    Future.delayed(const Duration(milliseconds: 500)).then(
                        (value) =>
                            Beamer.of(context).beamToNamed('/dashboard/$item'));
                  }
                }
              },
              itemBuilder: (BuildContext ctx) => <PopupMenuEntry<String>>[
                    ...orgs.map((e) => PopupMenuItem<String>(
                          value: e.id,
                          child: Text(e.name),
                        )),
                    const PopupMenuItem<String>(
                      value: '__neworg',
                      child: Text('New Organization'),
                    )
                  ]);
        });
  }
}
