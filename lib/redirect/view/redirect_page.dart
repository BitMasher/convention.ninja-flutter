import 'dart:async';

import 'package:flutter/material.dart';

class RedirectPage extends StatelessWidget {
  const RedirectPage({super.key, required route}) : _route = route;

  final String _route;

  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration.zero, () {
      unawaited(Navigator.of(context).popAndPushNamed(_route));
    });
    return const Text('');
  }
}
