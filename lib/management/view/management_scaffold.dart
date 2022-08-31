import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:organization_repository/organization_repository.dart';

import '../../app/bloc/app_bloc.dart';
import 'management_view.dart';

class ManagementScaffold extends StatelessWidget {
  const ManagementScaffold(
      {super.key,
      String? organizationId,
      required String selectionKey,
      required Widget child})
      : _organizationId = organizationId,
        _selectionKey = selectionKey,
        _child = child;

  final String? _organizationId;
  final String _selectionKey;
  final Widget _child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            automaticallyImplyLeading: false,
            elevation: 10,
            title: _OrganizationTitle(organizationId: _organizationId),
            centerTitle: true,
            actions: [
              _OrganizationDropdown(organizationId: _organizationId),
              const _LogoutButton()
            ]),
        body: _organizationId != null && _organizationId!.isNotEmpty
            ? ManagementView(
                organizationId: _organizationId!,
                selectionKey: _selectionKey,
                child: _child)
            : _child);
  }
}

class _OrganizationTitle extends StatelessWidget {
  const _OrganizationTitle({super.key, required String? organizationId})
      : _organizationId = organizationId;

  final String? _organizationId;

  @override
  Widget build(BuildContext context) {
    if (_organizationId == null || _organizationId!.isEmpty) {
      return const Text('Select an organization');
    }
    var org =
        context.read<OrganizationRepository>().getCached(_organizationId!);

    return org?.name != null
        ? Text(org!.name)
        : FutureBuilder<Organization?>(
            future:
                context.read<OrganizationRepository>().get(_organizationId!),
            initialData: null,
            builder: (ctx, snapshot) => snapshot.data == null
                ? Text(_organizationId!)
                : Text(snapshot.requireData!.name));
  }
}

class _OrganizationDropdown extends StatelessWidget {
  const _OrganizationDropdown({super.key, required String? organizationId})
      : _organizationId = organizationId;

  final String? _organizationId;

  @override
  Widget build(BuildContext context) {
    var orgs = context.read<OrganizationRepository>().getAllCached();
    return orgs != null
        ? _OrganizationPopupMenu(
            organizationId: _organizationId, organizations: orgs)
        : FutureBuilder<List<Organization>>(
            future: context.read<OrganizationRepository>().getAll(),
            initialData: const [],
            builder: (ctx, snapshot) {
              return _OrganizationPopupMenu(
                  organizationId: _organizationId,
                  organizations: snapshot.requireData);
            });
  }
}

class _OrganizationPopupMenu extends StatelessWidget {
  const _OrganizationPopupMenu({
    super.key,
    required String? organizationId,
    required List<Organization> organizations,
  })  : _organizationId = organizationId,
        _organizations = organizations;

  final String? _organizationId;
  final List<Organization> _organizations;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
        icon: const FaIcon(FontAwesomeIcons.sitemap),
        onSelected: (String item) {
          if (item == '__neworg') {
            context.go('/dashboard/new');
          } else if (item != _organizationId) {
            context.go('/dashboard/$item');
          }
        },
        itemBuilder: (ctx2) => <PopupMenuEntry<String>>[
              for (var organization in _organizations)
                PopupMenuItem<String>(
                  value: organization.id,
                  child: Text(organization.name),
                ),
              const PopupMenuItem<String>(
                  value: '__neworg', child: Text('New Organization'))
            ]);
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: const FaIcon(FontAwesomeIcons.arrowRightFromBracket),
        onPressed: () {
          context.read<AppBloc>().add(AppLogoutRequested());
        });
  }
}
