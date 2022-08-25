
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../services/organization_service.dart';

class DashboardCreationPage extends StatefulWidget {
  const DashboardCreationPage({Key? key}) : super(key: key);
  @override
  State<DashboardCreationPage> createState() => _DashboardCreationPage();
}

class _DashboardCreationPage extends State<DashboardCreationPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isInvalidAsync = false;
  String? _newName;

  @override
  Widget build(BuildContext context) {
    var beamParent = Beamer.of(context).parent;
    _formKey.currentState?.validate();
    return Center(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  hintText: 'Organization Name',
                ),
                validator: (String? value) {
                  if(value == null || value.isEmpty) {
                    return 'Please enter a valid name';
                  }
                  if(_isInvalidAsync) {
                    _isInvalidAsync = false;
                    return 'Organization name is already taken';
                  }
                  return null;
                },
                onSaved: (value) => _newName = value,
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        var res = await OrganizationService.create(_newName!);
                        if(res == null) {
                          setState(() {
                            _isInvalidAsync = true;
                          });
                        } else {
                          beamParent?.beamToNamed('/dashboard/${res.id}');
                        }
                      }
                    },
                    child: const Text('Submit')
                  )
                ),
              )
            ]
          ),
        )
      )
    );
  }

}