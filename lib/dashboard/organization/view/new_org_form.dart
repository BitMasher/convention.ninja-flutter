import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/new_organization_cubit.dart';

class NewOrgForm extends StatelessWidget {
  const NewOrgForm({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<NewOrganizationCubit, NewOrganizationState>(
      listener: (context, state) {
        if (state.status == NewOrganizationStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                duration: const Duration(seconds: 15),
                content: Text(
                    state.errorMessage ?? 'Failed to create organization')));
        } else if (state.status == NewOrganizationStatus.success) {
          context.go('/dashboard/${state.organization!.id}');
        }
      },
      child: Column(children: const [
        _OrganizationNameInput(),
        _SubmitButton(),
      ]),
    );
  }
}

class _OrganizationNameInput extends StatelessWidget {
  const _OrganizationNameInput({super.key});

  bool _isValid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewOrganizationCubit, NewOrganizationState>(
        buildWhen: (previous, current) => previous.name != current.name,
        builder: (context, state) {
          return TextField(
              key: const Key('newOrganizationForm_nameInput_textField'),
              onChanged: (name) =>
                  context.read<NewOrganizationCubit>().nameChanged(name),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: 'name',
                  helperText: '',
                  errorText: _isValid(state.name) ? null : 'invalid name'));
        });
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({super.key});

  bool _isValid(NewOrganizationState state) {
    return state.name.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Align(
            alignment: Alignment.centerRight,
            child: BlocBuilder<NewOrganizationCubit, NewOrganizationState>(
                buildWhen: (previous, current) => true,
                builder: (context, state) {
                  return ElevatedButton(
                      onPressed: !_isValid(state)
                          ? null
                          : () async {
                              context
                                  .read<NewOrganizationCubit>()
                                  .createOrganization();
                            },
                      child: const Text('Submit'));
                })));
  }
}
