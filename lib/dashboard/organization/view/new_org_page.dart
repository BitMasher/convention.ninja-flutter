import 'package:convention_ninja/dashboard/organization/cubit/new_organization_cubit.dart';
import 'package:convention_ninja/dashboard/organization/view/new_org_form.dart';
import 'package:convention_ninja/management/view/management_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:organization_repository/organization_repository.dart';

class NewOrgPage extends StatelessWidget {
  const NewOrgPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ManagementScaffold(
      selectionKey: '',
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: BlocProvider(
            create: (_) =>
                NewOrganizationCubit(context.read<OrganizationRepository>()),
            child: const NewOrgForm(),
          ),
        ),
      ),
    );
  }
}
