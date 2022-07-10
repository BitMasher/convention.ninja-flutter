import 'package:beamer/beamer.dart';
import 'package:convention_ninja/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({Key? key}) : super(key: key);

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _email;
  String? _name;
  String? _displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Form(
                key: _formKey,
                child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Contact Email',
                        ),
                        validator: (String? value) {
                          if (value == null ||
                              value.isEmpty ||
                              !value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (value) => _email = value,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Name',
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                        onSaved: (value) => _name = value,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Display Name',
                        ),
                        onSaved: (value) => _displayName = value,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState!.save();
                                    var res = await UserService.onboard(
                                        _name!, _email!, _displayName);
                                    if (res != null) {
                                      await UserService.me();
                                      Beamer.of(context)
                                          .beamToNamed('/dashboard');
                                    }
                                  }
                                },
                                child: const Text('Submit'))),
                      )
                    ])))));
  }
}
