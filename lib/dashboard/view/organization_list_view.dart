import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:organization_repository/organization_repository.dart';

class OrganizationListView extends StatelessWidget {
  const OrganizationListView({super.key});

  @override
  Widget build(BuildContext context) {
    var orgList = context.read<OrganizationRepository>().getAllCached();
    if (orgList == null) {
      return Center(
        child: FutureBuilder<List<Organization>>(
          future: context.read<OrganizationRepository>().getAll(),
          initialData: const [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return _OrganizationList(organizations: snapshot.requireData);
            }
            return const SelectableText("loading...");
          },
        ),
      );
    } else {
      return Center(
          child: _OrganizationList(
        organizations: orgList,
      ));
    }
  }
}

class _OrganizationList extends StatelessWidget {
  const _OrganizationList(
      {super.key, required List<Organization> organizations})
      : _organizations = organizations;
  final List<Organization> _organizations;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(8), children: <Widget>[
      for (var value in _organizations)
        ListTile(
            leading: const FaIcon(FontAwesomeIcons.solidFolder),
            title: Text(value.name),
            onTap: () {
              context.go('/dashboard/${value.id}');
            }),
      ListTile(
          leading: const FaIcon(FontAwesomeIcons.folderPlus),
          title: const Text('New Organization'),
          onTap: () {
            context.go('/dashboard/new');
          })
    ]);
  }
}
