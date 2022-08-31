import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../cubit/login_cubit.dart';

class LoginCard extends StatelessWidget {
  const LoginCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Authentication Failure'),
              ),
            );
        }
      },
      child: Card(
          child: SizedBox(
        width: 250.0,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const ListTile(
            title: Center(child: Text('Login to Convention.Ninja')),
          ),
          const Divider(),
          _GoogleLoginButton(),
          const Divider(),
          _FacebookLoginButton(),
        ]),
      )),
    );
  }
}

class _GoogleLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const FaIcon(FontAwesomeIcons.google),
        title: const Text('Login with Google'),
        enabled: true,
        onTap: () => context.read<LoginCubit>().logInWithGoogle());
  }
}

class _FacebookLoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: const FaIcon(FontAwesomeIcons.facebook),
        title: const Text('Login with Facebook'),
        enabled: true,
        onTap: () => context.read<LoginCubit>().logInWithFacebook());
  }
}
