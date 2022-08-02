import 'package:flutter/material.dart';

import '../services/inventory_service.dart';

class InventoryModelsPage extends StatelessWidget {
  const InventoryModelsPage({Key? key, required this.orgId}) : super(key: key);
  final String orgId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ModelsDataTable(orgId: orgId),
    );
  }
}

class ModelsDataTable extends StatefulWidget {
  const ModelsDataTable({
    Key? key,
    required this.orgId,
  }) : super(key: key);

  final String orgId;

  @override
  State<ModelsDataTable> createState() => _ModelsDataTableState();
}

class _ModelsDataTableState extends State<ModelsDataTable> {
  final GlobalKey<FormFieldState<String>> _newModelField =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _newCatField =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _newMfgField =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _editModelField =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _editCatField =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _editMfgField =
      GlobalKey<FormFieldState<String>>();
  final TextEditingController _controller = TextEditingController();
  late Future<List<Model>> _models;
  String _editId = '';
  String? _updateName;
  String? _updateCatId;
  String? _updateMfgId;
  String? _newName;
  String? _newCatId;
  String? _newMfgId;
  bool _asyncNewValidation = true;
  bool _asyncEditValidation = true;

  @override
  void initState() {
    super.initState();
    _models = InventoryService.getModels(widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_asyncNewValidation) {
      _newModelField.currentState?.validate();
    }
    if (!_asyncEditValidation) {
      _editModelField.currentState?.validate();
    }
    return FutureBuilder<List<Model>>(
        future: _models,
        initialData: const [],
        builder: (context, snapshot) {
          return Table(
            border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
            defaultColumnWidth: const IntrinsicColumnWidth(),
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
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Category')),
                )),
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Manufacturer')),
                )),
                TableCell(child: Text(''))
              ]),
              for (var entry in snapshot.data!) buildDataRow(entry, snapshot),
              buildNewRow(snapshot)
            ],
          );
        });
  }

  TableRow buildNewRow(AsyncSnapshot<List<Model>> snapshot) {
    return TableRow(children: [
      const TableCell(child: Text('')),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: _newModelField,
                decoration: const InputDecoration(hintText: 'Model Name'),
                onFieldSubmitted: (_) async {
                  await onNewSubmit();
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid model name';
                  }
                  if (!_asyncNewValidation) {
                    return 'Model already exists';
                  }
                  return null;
                },
                onSaved: (val) {
                  _newName = val;
                },
              ))),
      TableCell(
          child: FutureBuilder(
        future: InventoryService.getCategories(widget.orgId),
        builder:
            (BuildContext context, AsyncSnapshot<List<Category>> snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
                key: _newCatField,
                hint: const Text('Category'),
                value: _newCatId,
                items: snapshot.hasData
                    ? snapshot.data
                        ?.map((e) => DropdownMenuItem<String>(
                            value: e.id, child: Text(e.name)))
                        .toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _newCatId = newValue;
                  });
                }),
          );
        },
      )),
      TableCell(
          child: FutureBuilder(
        future: InventoryService.getManufacturers(widget.orgId),
        builder:
            (BuildContext context, AsyncSnapshot<List<Manufacturer>> snapshot) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
                key: _newMfgField,
                hint: const Text('Manufacturer'),
                value: _newMfgId,
                items: snapshot.hasData
                    ? snapshot.data
                        ?.map((e) => DropdownMenuItem<String>(
                            value: e.id, child: Text(e.name)))
                        .toList()
                    : [],
                onChanged: (String? newValue) {
                  setState(() {
                    _newMfgId = newValue;
                  });
                }),
          );
        },
      )),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                  onPressed: onNewSubmit, child: const Text('Save'))))
    ]);
  }

  Future<void> onNewSubmit() async {
    _asyncNewValidation = true;
    if (!_newModelField.currentState!.validate() ||
        _newCatId == null ||
        _newMfgId == null) {
      return;
    }
    _newModelField.currentState?.save();
    var model = await InventoryService.createModel(
        widget.orgId, _newName!, _newCatId!, _newMfgId!);
    if (model == null) {
      setState(() {
        _asyncNewValidation = false;
      });
    } else {
      setState(() {
        _newName = null;
        _newModelField.currentState?.reset();
        _newCatId = null;
        _newCatField.currentState?.reset();
        _newMfgId = null;
        _newMfgField.currentState?.reset();
        _asyncNewValidation = true;
        _models = InventoryService.getModels(widget.orgId);
      });
    }
  }

  TableRow buildDataRow(Model entry, AsyncSnapshot<List<Model>> snapshot) {
    return TableRow(children: [
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0), child: SelectableText(entry.id))),
      TableCell(
          child: (_editId == entry.id)
              ? Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                    key: _editModelField,
                    controller: _controller,
                    decoration: const InputDecoration(hintText: 'Updated Name'),
                    autofocus: true,
                    onFieldSubmitted: (_) async {
                      await onUpdateSubmit(entry);
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter a valid name';
                      }
                      if (!_asyncEditValidation) {
                        return 'Model already exists';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _updateName = val;
                    },
                  ),
              )
              : GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _editId = entry.id;
                      _editModelField.currentState?.reset();
                      _controller.text = entry.name;
                      _updateName = entry.name;
                      _updateCatId = entry.categoryId;
                      _updateMfgId = entry.manufacturerId;
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(entry.name)),
                )),
      TableCell(
          child: (_editId == entry.id)
              ? FutureBuilder(
                  future: InventoryService.getCategories(widget.orgId),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Category>> snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                          key: _editCatField,
                          value: _updateCatId,
                          items: snapshot.hasData
                              ? snapshot.data
                                  ?.map((e) => DropdownMenuItem<String>(
                                      value: e.id, child: Text(e.name)))
                                  .toList()
                              : [],
                          onChanged: (String? newValue) {
                            setState(() {
                              _updateCatId = newValue;
                            });
                          }),
                    );
                  },
                )
              : GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _editId = entry.id;
                      _editModelField.currentState?.reset();
                      _controller.text = entry.name;
                      _updateName = entry.name;
                      _updateCatId = entry.categoryId;
                      _updateMfgId = entry.manufacturerId;
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(entry.category?.name ?? entry.categoryId)),
                )),
      TableCell(
          child: (_editId == entry.id)
              ? FutureBuilder(
                  future: InventoryService.getManufacturers(widget.orgId),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Manufacturer>> snapshot) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                          key: _editMfgField,
                          value: _updateMfgId,
                          items: snapshot.hasData
                              ? snapshot.data
                                  ?.map((e) => DropdownMenuItem<String>(
                                      value: e.id, child: Text(e.name)))
                                  .toList()
                              : [],
                          onChanged: (String? newValue) {
                            setState(() {
                              _updateMfgId = newValue;
                            });
                          }),
                    );
                  },
                )
              : GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _editId = entry.id;
                      _editModelField.currentState?.reset();
                      _controller.text = entry.name;
                      _updateName = entry.name;
                      _updateCatId = entry.categoryId;
                      _updateMfgId = entry.manufacturerId;
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SelectableText(
                          entry.manufacturer?.name ?? entry.manufacturerId)),
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
                  _editModelField.currentState?.reset();
                  _controller.text = entry.name;
                  _updateName = entry.name;
                  _updateCatId = entry.categoryId;
                  _updateMfgId = entry.manufacturerId;
                });
              },
              child: const Text('Edit')),
        if (_editId != entry.id)
          ElevatedButton(
              onPressed: () async {
                await InventoryService.deleteModel(widget.orgId, entry.id);
                setState(() {
                  _asyncEditValidation = true;
                  _models = InventoryService.getModels(widget.orgId);
                });
              },
              child: const Text('Delete')),
      ]))
    ]);
  }

  Future<void> onUpdateSubmit(Model entry) async {
    _asyncEditValidation = true;
    if (!_editModelField.currentState!.validate() ||
        _updateCatId == null ||
        _updateMfgId == null) {
      return;
    }
    _editModelField.currentState?.save();
    if (_updateName == entry.name &&
        _updateCatId == entry.categoryId &&
        _updateMfgId == entry.manufacturerId) {
      setState(() {
        _editId = '';
        _updateName = null;
        _updateCatId = null;
        _updateMfgId = null;
        _asyncEditValidation = true;
      });
      return;
    }
    if (_updateName == null) {
      setState(() {
        _editId = '';
        _asyncEditValidation = true;
      });
      return;
    }
    var model = await InventoryService.updateModel(widget.orgId, entry.id,
        name: _updateName == entry.name ? null : _updateName,
        categoryId: _updateCatId == entry.categoryId ? null : _updateCatId,
        manufacturerId:
            _updateMfgId == entry.manufacturerId ? null : _updateMfgId);
    if (model == null) {
      setState(() {
        _asyncEditValidation = false;
      });
    } else {
      setState(() {
        _editId = '';
        _updateName = null;
        _updateCatId = null;
        _updateMfgId = null;
        _asyncEditValidation = true;
        _models = InventoryService.getModels(widget.orgId);
      });
    }
    return;
  }
}
