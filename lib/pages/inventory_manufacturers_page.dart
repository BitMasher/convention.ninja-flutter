import 'package:flutter/material.dart';

import '../services/inventory_service.dart';

class InventoryManufacturersPage extends StatelessWidget {
  const InventoryManufacturersPage({Key? key, required this.orgId})
      : super(key: key);
  final String orgId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ManufacturersDataTable(orgId: orgId),
    );
  }
}

class ManufacturersDataTable extends StatefulWidget {
  const ManufacturersDataTable({
    Key? key,
    required this.orgId,
  }) : super(key: key);

  final String orgId;

  @override
  State<ManufacturersDataTable> createState() => _ManufacturersDataTableState();
}

class _ManufacturersDataTableState extends State<ManufacturersDataTable> {
  final GlobalKey<FormFieldState<String>> _newMfgField =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _editMfgField =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _controller = TextEditingController();
  late Future<List<Manufacturer>> _manufacturers;
  String _editId = '';
  String? _updateName;
  String? _newName;
  bool _asyncNewValidation = true;
  bool _asyncEditValidation = true;

  @override
  void initState() {
    super.initState();
    _manufacturers = InventoryService.getManufacturers(widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_asyncNewValidation) {
      _newMfgField.currentState?.validate();
    }
    if (!_asyncEditValidation) {
      _editMfgField.currentState?.validate();
    }
    return FutureBuilder<List<Manufacturer>>(
        future: _manufacturers,
        initialData: const [],
        builder: (context, snapshot) {
          return Table(
            border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
            children: [
              const TableRow(children: [
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Id')),
                )),
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Name')),
                )),
                TableCell(child: Text(''))
              ]),
              for (var entry in snapshot.data!) buildDataRow(entry, snapshot),
              buildNewRow(snapshot)
            ],
          );
        });
  }

  TableRow buildNewRow(AsyncSnapshot<List<Manufacturer>> snapshot) {
    return TableRow(children: [
      const TableCell(child: Text('')),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: _newMfgField,
                decoration:
                    const InputDecoration(hintText: 'Manufacturer Name'),
                onFieldSubmitted: (_) async {
                  await onNewSubmit();
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid manufacturer name';
                  }
                  if (snapshot.data!.any((element) =>
                      element.name.toLowerCase() == value.toLowerCase())) {
                    return 'Manufacturer already exists';
                  }
                  if (!_asyncNewValidation) {
                    return 'Manufacturer already exists';
                  }
                  return null;
                },
                onSaved: (val) {
                  _newName = val;
                },
              ))),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: onNewSubmit, child: const Text('Save'))))
    ]);
  }

  Future<void> onNewSubmit() async {
    _asyncNewValidation = true;
    if (!_newMfgField.currentState!.validate()) {
      return;
    }
    _newMfgField.currentState?.save();
    var cat =
        await InventoryService.createManufacturer(widget.orgId, _newName!);
    if (cat == null) {
      setState(() {
        _asyncNewValidation = false;
      });
    } else {
      setState(() {
        _newName = null;
        _newMfgField.currentState?.reset();
        _asyncNewValidation = true;
        _manufacturers = InventoryService.getManufacturers(widget.orgId);
      });
    }
  }

  TableRow buildDataRow(
      Manufacturer entry, AsyncSnapshot<List<Manufacturer>> snapshot) {
    return TableRow(children: [
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0), child: SelectableText(entry.id))),
      TableCell(
          child: (_editId == entry.id)
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    key: _editMfgField,
                    decoration: const InputDecoration(hintText: 'Updated Name'),
                    controller: _controller,
                    autofocus: true,
                    onFieldSubmitted: (_) async {
                      await onUpdateSubmit(entry);
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter a valid name';
                      }
                      if (val != entry.name &&
                          snapshot.data!.any((element) =>
                              element.name.toLowerCase() == val.toLowerCase())) {
                        return 'Manufacturer already exists';
                      }
                      if (!_asyncEditValidation) {
                        return 'Manufacturer already exists';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      if (val == entry.name) {
                        _updateName = null;
                      } else {
                        _updateName = val;
                      }
                    },
                  ),
              )
              : GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _editId = entry.id;
                      _controller.text = entry.name;
                      _asyncEditValidation = true;
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(entry.name)),
                )),
      TableCell(
          child: Row(children: [
        if (_editId == entry.id)
          ElevatedButton(
              onPressed: () async {
                await onUpdateSubmit(entry);
              },
              child: const Text('Save')),
        if (_editId == entry.id)
          ElevatedButton(
              onPressed: () {
                setState(() {
                  _editId = '';
                  _asyncEditValidation = true;
                });
              },
              child: const Text('Cancel')),
        if (_editId != entry.id)
          ElevatedButton(
              onPressed: () async {
                setState(() {
                  _editId = entry.id;
                  _controller.text = entry.name;
                });
              },
              child: const Text('Edit')),
        if (_editId != entry.id)
          ElevatedButton(
              onPressed: () async {
                await InventoryService.deleteManufacturer(
                    widget.orgId, entry.id);
                setState(() {
                  _asyncEditValidation = true;
                  _manufacturers =
                      InventoryService.getManufacturers(widget.orgId);
                });
              },
              child: const Text('Delete')),
      ]))
    ]);
  }

  Future<void> onUpdateSubmit(Manufacturer entry) async {
    _asyncEditValidation = true;
    if (!_editMfgField.currentState!.validate()) {
      return;
    }
    _editMfgField.currentState?.save();
    if (_updateName == null) {
      setState(() {
        _editId = '';
        _asyncEditValidation = true;
      });
      return;
    }
    var cat = await InventoryService.updateManufacturer(
        widget.orgId, entry.id, _updateName!);
    if (cat == null) {
      setState(() {
        _asyncEditValidation = false;
      });
    } else {
      setState(() {
        _editId = '';
        _updateName = null;
        _asyncEditValidation = true;
        _manufacturers = InventoryService.getManufacturers(widget.orgId);
      });
    }
    return;
  }
}
