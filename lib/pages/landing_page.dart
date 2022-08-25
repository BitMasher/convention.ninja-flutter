import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Card(
                child: Container(
      width: 250.0,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const ListTile(
          title: Center(child: Text('Login to Convention.Ninja')),
        ),
        const Divider(),
        ListTile(
            leading: const FaIcon(FontAwesomeIcons.google),
            title: const Text('Login with Google'),
            enabled: true,
            onTap: () {
              FirebaseAuth.instance.signInWithRedirect(GoogleAuthProvider());
            }),
        const Divider(),
        ListTile(
            leading: const FaIcon(FontAwesomeIcons.facebook),
            title: const Text('Login with Facebook'),
            enabled: true,
            onTap: () {
              FirebaseAuth.instance.signInWithRedirect(FacebookAuthProvider());
            })
      ]),
    ))));
  }
}
