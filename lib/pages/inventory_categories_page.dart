import 'package:flutter/material.dart';

import '../services/inventory_service.dart';

class InventoryCategoriesPage extends StatelessWidget {
  const InventoryCategoriesPage({Key? key, required this.orgId})
      : super(key: key);
  final String orgId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CategoriesDataTable(orgId: orgId),
    );
  }
}

class CategoriesDataTable extends StatefulWidget {
  const CategoriesDataTable({
    Key? key,
    required this.orgId,
  }) : super(key: key);

  final String orgId;

  @override
  State<CategoriesDataTable> createState() => _CategoriesDataTableState();
}

class _CategoriesDataTableState extends State<CategoriesDataTable> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<FormFieldState<String>> _newCatField =
      GlobalKey<FormFieldState<String>>();
  final GlobalKey<FormFieldState<String>> _editCatField =
      GlobalKey<FormFieldState<String>>();
  late Future<List<Category>> _categories;
  String _editId = '';
  String? _updateName;
  String? _newName;
  bool _asyncNewValidation = true;
  bool _asyncEditValidation = true;

  @override
  void initState() {
    super.initState();
    _categories = InventoryService.getCategories(widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    if (!_asyncNewValidation) {
      _newCatField.currentState?.validate();
    }
    if (!_asyncEditValidation) {
      _editCatField.currentState?.validate();
    }
    return FutureBuilder<List<Category>>(
        future: _categories,
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

  TableRow buildNewRow(AsyncSnapshot<List<Category>> snapshot) {
    return TableRow(children: [
      const TableCell(child: Text('')),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                key: _newCatField,
                decoration: const InputDecoration(hintText: 'Category Name'),
                onFieldSubmitted: (_) async {
                  await onNewSubmit();
                },
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a valid category name';
                  }
                  if (snapshot.data!.any((element) =>
                      element.name.toLowerCase() == value.toLowerCase())) {
                    return 'Category already exists';
                  }
                  if (!_asyncNewValidation) {
                    return 'Category already exists';
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
                  onPressed: onNewSubmit,
                  child: const Text('Save'))))
    ]);
  }

  Future<void> onNewSubmit() async {
                  if (!_newCatField.currentState!.validate()) {
                    return;
                  }
                  _newCatField.currentState?.save();
                  var cat = await InventoryService.createCategory(
                      widget.orgId, _newName!);
                  if (cat == null) {
                    setState(() {
                      _asyncNewValidation = false;
                    });
                  } else {
                    setState(() {
                      _newName = null;
                      _asyncNewValidation = true;
                      _categories =
                          InventoryService.getCategories(widget.orgId);
                    });
                  }
                }

  TableRow buildDataRow(
      Category entry, AsyncSnapshot<List<Category>> snapshot) {
    return TableRow(children: [
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0), child: Text(entry.id))),
      TableCell(
          child: (_editId == entry.id)
              ? TextFormField(
                  key: _editCatField,
                  decoration: const InputDecoration(hintText: 'Updated Name'),
                  initialValue: entry.name,
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
                      return 'Category already exists';
                    }
                    if (!_asyncEditValidation) {
                      return 'Category already exists';
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
                )
              : GestureDetector(
                  onDoubleTap: () {
                    setState(() {
                      _editId = entry.id;
                    });
                  },
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(entry.name)),
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
                await InventoryService.deleteCategory(widget.orgId, entry.id);
                setState(() {
                  _asyncEditValidation = true;
                  _categories = InventoryService.getCategories(widget.orgId);
                });
              },
              child: const Text('Delete')),
      ]))
    ]);
  }

  Future<void> onUpdateSubmit(Category entry) async {
    if (!_editCatField.currentState!.validate()) {
      return;
    }
    _editCatField.currentState?.save();
    if (_updateName == null) {
      setState(() {
        _editId = '';
        _asyncEditValidation = true;
      });
      return;
    }
    var cat = await InventoryService.updateCategory(
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
        _categories = InventoryService.getCategories(widget.orgId);
      });
    }
    return;
  }
}
