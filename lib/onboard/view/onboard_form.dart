import 'package:convention_ninja/onboard/onboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OnboardForm extends StatelessWidget {
  const OnboardForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: const [
      _EmailInput(),
      _NameInput(),
      _DisplayNameInput(),
      Padding(
        padding: EdgeInsets.all(8.0),
        child: Align(alignment: Alignment.centerRight, child: _SubmitButton()),
      )
    ]);
  }
}

class _EmailInput extends StatelessWidget {
  const _EmailInput({super.key});

  bool _isValid(String? value) {
    if (value == null || value.isEmpty || !value.contains('@')) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardCubit, OnboardState>(
        buildWhen: (previous, current) => previous.email != current.email,
        builder: (context, state) {
          return TextField(
              key: const Key('onboardForm_emailInput_textField'),
              onChanged: (email) =>
                  context.read<OnboardCubit>().emailChanged(email),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  labelText: 'email',
                  helperText: '',
                  errorText: _isValid(state.email) ? null : 'invalid email'));
        });
  }
}

class _NameInput extends StatelessWidget {
  const _NameInput({super.key});

  bool _isValid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardCubit, OnboardState>(
        buildWhen: (previous, current) => previous.name != current.name,
        builder: (context, state) {
          return TextField(
              key: const Key('onboardForm_nameInput_textField'),
              onChanged: (name) =>
                  context.read<OnboardCubit>().nameChanged(name),
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                  labelText: 'name',
                  helperText: '',
                  errorText: _isValid(state.name) ? null : 'invalid name'));
        });
  }
}

class _DisplayNameInput extends StatelessWidget {
  const _DisplayNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardCubit, OnboardState>(
        buildWhen: (previous, current) =>
            previous.displayName != current.displayName,
        builder: (context, state) {
          return TextField(
              key: const Key('onboardForm_displayNameInput_textField'),
              onChanged: (displayName) =>
                  context.read<OnboardCubit>().displayNameChanged(displayName),
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: 'display name',
                helperText: '',
              ));
        });
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({super.key});

  bool _isValid(OnboardState state) {
    return state.email.contains('@') && state.name.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OnboardCubit, OnboardState>(
        buildWhen: (previous, current) => true,
        builder: (context, state) {
          return ElevatedButton(
              onPressed: !_isValid(state)
                  ? null
                  : () async {
                      context.read<OnboardCubit>().onboard();
                    },
              child: const Text('Submit'));
        });
  }
}
