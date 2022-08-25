import 'package:flutter/material.dart';

import '../services/organization_service.dart';

class AsyncOrganizationTitle extends StatelessWidget {
  const AsyncOrganizationTitle({
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
      initialData: [
        Organization(
            id: organizationId,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            name: organizationId,
            ownerId: '')
      ],
      builder: (_, snapshot) {
        for (var value in snapshot.requireData) {
          if (value.id == organizationId) {
            return Text(value.name);
          }
        }
        if (organizationId == "new") {
          return const Text("New Organization");
        }
        return Text(organizationId);
      },
    );
  }
}
