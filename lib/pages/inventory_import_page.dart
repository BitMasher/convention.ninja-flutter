import 'package:convention_ninja/services/csv_processor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';

import '../services/inventory_service.dart';

class StatusPair<V> {
  String status;
  V value;
  StatusPair({required this.status, required this.value});
}

class InventoryImportPage extends StatefulWidget {
  final String orgId;

  const InventoryImportPage({Key? key, required this.orgId}) : super(key: key);

  @override
  State<InventoryImportPage> createState() => _InventoryImportPageState();
}

class _InventoryImportPageState extends State<InventoryImportPage> {
  String? _error;

  final List<bool> _expanded = List.filled(4, false);
  FilePickerResult? _fileSelection;
  final ValueNotifier<double> _catProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _mfgProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _modelProgress = ValueNotifier<double>(0.0);
  final ValueNotifier<double> _assetProgress = ValueNotifier<double>(0.0);
  Map<String, StatusPair<Category>> _categories = <String, StatusPair<Category>>{};
  Map<String, StatusPair<Manufacturer>> _manufacturers = <String, StatusPair<Manufacturer>>{};
  Map<String, StatusPair<Model>> _models = <String, StatusPair<Model>>{};
  Map<String, StatusPair<Asset>> _assets = <String, StatusPair<Asset>>{};
  bool _processing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> processCategories() async {
    var exists = _categories.values.where((element) => element.status == 'Exists').length;
    var count = _categories.length;
    if(count == 0) {
      _catProgress.value = 1;
      return;
    }
    for(var cat in _categories.values) {
      if(cat.status == 'New') {
        var newCat = await InventoryService.createCategory(widget.orgId, cat.value.name);
        if(newCat == null) {
          cat.status = 'Error';
        } else {
          cat.status = 'Created';
          cat.value = newCat;
        }
        exists++;
        _catProgress.value = (exists/count);
      }
    }
  }
  Future<void> processManufacturers() async {
    var exists = _manufacturers.values.where((element) => element.status == 'Exists').length;
    var count = _manufacturers.length;
    if(count == 0) {
      _mfgProgress.value = 1;
      return;
    }
    for(var mfg in _manufacturers.values) {
      if(mfg.status == 'New') {
        var newMfg = await InventoryService.createManufacturer(widget.orgId, mfg.value.name);
        if(newMfg == null) {
          mfg.status = 'Error';
        } else {
          mfg.status = 'Created';
          mfg.value = newMfg;
        }
        exists++;
        _mfgProgress.value = (exists/count);
      }
    }
  }
  Future<void> processModels() async {
    var exists = _models.values.where((element) => element.status == 'Exists').length;
    var count = _models.length;
    if(count == 0) {
      _modelProgress.value = 1;
      return;
    }
    for(var model in _models.values) {
      if(model.status == 'New') {
        var newModel = await InventoryService.createModel(widget.orgId, model.value.name, _categories[model.value.category!.name.toLowerCase()]!.value.id, _manufacturers[model.value.manufacturer!.name.toLowerCase()]!.value.id);
        if(newModel == null) {
          model.status = 'Error';
        } else {
          model.status = 'Created';
          model.value = newModel;
        }
        exists++;
        _modelProgress.value = (exists/count);
      }
    }
  }
  Future<void> processAssets() async {
    var exists = _assets.values.where((element) => element.status == 'Exists').length;
    var count = _assets.length;
    if(count == 0) {
      _assetProgress.value = 1;
      return;
    }
    for(var asset in _assets.values) {
      if(asset.status == 'New') {
        var newAsset = await InventoryService.createAsset(widget.orgId, _models["${asset.value.model!.name}-${asset.value.model!.manufacturer!.name}".toLowerCase()]!.value.id, null, asset.value.assetTags.map((t)=>t.tagId).toList());
        if(newAsset == null) {
          asset.status = 'Error';
        } else {
          asset.status = 'Created';
          asset.value = newAsset;
        }
        exists++;
        _assetProgress.value = (exists/count);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(children: [
        Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 0),
              child: SizedBox(
                width: 300,
                height: 150,
                child: Card(
                  child: Stack(children: [
                    if (_error != null && _error?.isNotEmpty == true)
                      Expanded(
                          child: Align(
                              alignment: Alignment.topCenter,
                              child: SelectableText(_error!,
                                  style: const TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold)))),
                    Row(children: [
                      SizedBox(
                        width: 292,
                        height: 315,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            Text(_fileSelection?.names.first ?? ""),
                            ElevatedButton(
                                onPressed: () async {
                                  FilePickerResult? result = await FilePicker.platform.pickFiles();
                                  if(result == null) {
                                    return;
                                  }
                                  if(result.isSinglePick == false) {
                                    setState((){
                                      _error = "Only one file may be processed at a time";
                                    });
                                    return;
                                  }
                                  var csv = CsvFile.fromBytes(result.files.first.bytes!);
                                  if(csv == null) {
                                    setState((){_error = "Invalid csv file";});
                                    return;
                                  }
                                  if(csv.headers.isEmpty) {
                                    setState((){_error = "File must contain a headers row";});
                                    return;
                                  }
                                  if(csv.headers.contains('Category')) {
                                    var existingCats = await InventoryService.getCategories(widget.orgId);
                                    _categories = {
                                      for (var e in csv.rows.map<String>((e) => e['Category']!).toSet().map((e) {
                                      if(existingCats.any((element) => element.name.toLowerCase() == e.toLowerCase())) {
                                        return StatusPair(status: "Exists", value: existingCats.firstWhere((element) => element.name.toLowerCase() == e.toLowerCase()));
                                      }
                                      else {
                                          return StatusPair(status: "New",
                                          value: Category(id: '',
                                              createdAt: DateTime.now(),
                                              updatedAt: DateTime.now(),
                                              name: e,
                                              organizationId: widget.orgId));
                                      }
                                      }))
                                        e.value.name.toLowerCase() : e
                                    };
                                  }
                                  if(csv.headers.contains('Manufacturer')) {
                                    var existingMfgs = await InventoryService.getManufacturers(widget.orgId);
                                    _manufacturers = {
                                      for (var e in csv.rows.map<String>((e) => e['Manufacturer']!).toSet().map((e) {
                                        if(existingMfgs.any((element) => element.name.toLowerCase() == e.toLowerCase())) {
                                          return StatusPair(status: "Exists", value: existingMfgs.firstWhere((element) => element.name.toLowerCase() == e.toLowerCase()));
                                        }
                                        else {
                                          return StatusPair(status: "New",
                                              value: Manufacturer(id: '',
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                  name: e,
                                                  organizationId: widget.orgId));
                                        }
                                      }))
                                        e.value.name.toLowerCase() : e
                                    };
                                  }
                                  if(csv.headers.contains('Model')) {
                                    if(!csv.headers.contains('Manufacturer') || !csv.headers.contains('Category')) {
                                      setState((){
                                        _error = "Model header requires Manufacturer and Category headers";
                                      });
                                      return;
                                    }
                                    var existingModels = await InventoryService.getModels(widget.orgId);
                                    _models = {
                                      for (var e in csv.rows.map((e) {
                                        if(existingModels.any((element) => element.name.toLowerCase() == e['Model']!.toLowerCase() && element.manufacturer?.name.toLowerCase() == e['Manufacturer']!.toLowerCase())) {
                                          return StatusPair(status: "Exists", value: existingModels.firstWhere((element) => element.name.toLowerCase() == e['Model']!.toLowerCase() && element.manufacturer?.name.toLowerCase() == e['Manufacturer']!.toLowerCase()));
                                        }
                                        else {
                                          var testMfg = _manufacturers[e['Manufacturer']!.toLowerCase()]!;
                                          var testCat = _categories[e['Category']!.toLowerCase()]!;
                                          return StatusPair(status: "New",
                                              value: Model(id: '',
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                  name: e['Model']!,
                                                  manufacturerId: testMfg.value.id,
                                                  manufacturer: testMfg.value,
                                                  categoryId: testCat.value.id,
                                                  category: testCat.value,
                                                  organizationId: widget.orgId));
                                        }
                                      }))
                                        "${e.value.name}-${e.value.manufacturer?.name}".toLowerCase() : e
                                    };
                                  }
                                  if(csv.headers.contains('Asset Tag')) {
                                    if(!csv.headers.contains('Manufacturer') || !csv.headers.contains('Category') || !csv.headers.contains('Model')) {
                                      setState((){
                                        _error = "Asset Tag header requires Model, Manufacturer and Category headers";
                                      });
                                      return;
                                    }
                                    var existingAssets = await InventoryService.getAssets(widget.orgId);
                                    _assets = {
                                      for (var e in csv.rows.map((e) {
                                        if(existingAssets.any((element) => element.assetTags.any((tag) => tag.tagId.toLowerCase() == e['Asset Tag']!.toLowerCase()))) {
                                          return StatusPair(status: "Exists", value: existingAssets.firstWhere((element) => element.assetTags.any((tag) => tag.tagId.toLowerCase() == e['Asset Tag']!.toLowerCase())));
                                        }
                                        else {
                                          var testModel = _models["${e['Model']}-${e['Manufacturer']}".toLowerCase()]!;
                                          return StatusPair(status: "New",
                                              value: Asset(id: '',
                                                  createdAt: DateTime.now(),
                                                  updatedAt: DateTime.now(),
                                                  modelId: testModel.value.id,
                                                  model: testModel.value,
                                                  organizationId: widget.orgId,
                                                  roomId: e['Location'] ?? 'Unknown',
                                                assetTags: [AssetTag(id: '', createdAt: DateTime.now(), updatedAt: DateTime.now(), tagId: e['Asset Tag']!, assetId: '', organizationId: widget.orgId)]
                                              ));
                                        }
                                      }))
                                        e.value.assetTags[0].tagId.toLowerCase() : e
                                    };
                                  }
                                  _catProgress.value = (_categories.values.where((e) => e.status == 'Exists').length/_categories.keys.length);
                                  _mfgProgress.value = (_manufacturers.values.where((e) => e.status == 'Exists').length/_manufacturers.keys.length);
                                  _modelProgress.value = (_models.values.where((e) => e.status == 'Exists').length/_models.keys.length);
                                  _assetProgress.value = (_assets.values.where((e) => e.status == 'Exists').length/_assets.keys.length);
                                  setState(() {
                                    _fileSelection = result;
                                  });
                                }, child: const Text("Select File"))
                          ]),
                        ),
                      ),
                    ]),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  if(_processing) {
                                    return;
                                  }
                                  _processing = true;
                                  await processCategories();
                                  await processManufacturers();
                                  await processModels();
                                  await processAssets();
                                  _processing = false;
                                  setState((){});
                                },
                                child: const Text("Import"),
                              ),
                            ],
                          )),
                    ),
                  ]),
                ),
              ),
            )),
        Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 20, 8.0, 8.0),
            child: ExpansionPanelList(
                expansionCallback: (int idx, bool isExpanded) {
                  setState(() {
                    _expanded[idx] = !isExpanded;
                  });
                },
                children: [
              ExpansionPanel(
              isExpanded: _expanded[0],
              canTapOnHeader: true,
              headerBuilder: (BuildContext ctx, bool isExpanded) {
                return ListTile(title: Text('Categories - ${_categories.values.where((element) => element.status == "New").length} new - ${_categories.values.where((element) => element.status == "Exists").length} existing - ${_categories.values.where((element) => element.status == "Created").length} Created - ${_categories.values.where((element) => element.status == "Error").length} Errors'),
                subtitle: ValueListenableBuilder<double>(
                  valueListenable: _catProgress,
                    builder: (ctx, dbl, _) {
                      return LinearProgressIndicator(value: dbl);
                    }));
              },
              body: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(width: 1.0)),
                children: [
                  const TableRow(children: [
                    TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Name")),
                    )),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text("Status")),
                      ),
                    ),
                  ]),
                  for(var catitem in _categories.values)
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text(catitem.value.name)),
                          )),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text(catitem.status)),
                        ),
                      ),
                    ]),
                ],
              )),
              ExpansionPanel(
              isExpanded: _expanded[1],
              canTapOnHeader: true,
              headerBuilder: (BuildContext ctx, bool isExpanded) {
                return ListTile(title: Text('Manufacturers - ${_manufacturers.values.where((element) => element.status == "New").length} new - ${_manufacturers.values.where((element) => element.status == "Exists").length} existing - ${_manufacturers.values.where((element) => element.status == "Created").length} Created - ${_manufacturers.values.where((element) => element.status == "Error").length} Errors'),
                    subtitle: ValueListenableBuilder<double>(
                        valueListenable: _mfgProgress,
                        builder: (ctx, dbl, _) {
                          return LinearProgressIndicator(value: dbl);
                        }));
              },
              body: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(width: 1.0)),
                children: [
                  const TableRow(children: [
                    TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Name")),
                    )),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text("Status")),
                      ),
                    ),
                  ]),
                  for(var mfgitem in _manufacturers.values)
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text(mfgitem.value.name)),
                          )),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text(mfgitem.status)),
                        ),
                      ),
                    ]),
                ],
              )),
              ExpansionPanel(
              isExpanded: _expanded[2],
              canTapOnHeader: true,
              headerBuilder: (BuildContext ctx, bool isExpanded) {
                return ListTile(title: Text('Models - ${_models.values.where((element) => element.status == "New").length} new - ${_models.values.where((element) => element.status == "Exists").length} existing - ${_models.values.where((element) => element.status == "Created").length} Created - ${_models.values.where((element) => element.status == "Error").length} Errors'),
                    subtitle: ValueListenableBuilder<double>(
                        valueListenable: _modelProgress,
                        builder: (ctx, dbl, _) {
                          return LinearProgressIndicator(value: dbl);
                        }));
              },
              body: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(width: 1.0)),
                children: [
                  const TableRow(children: [
                    TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Name")),
                    )),
                    TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Manufacturer")),
                    )),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text('Category')),
                      )),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text("Status")),
                      ),
                    ),
                  ]),
                  for(var modelitem in _models.values)
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text(modelitem.value.name)),
                          )),
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text(modelitem.value.manufacturer?.name ?? '')),
                          )),
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text(modelitem.value.category?.name ?? '')),
                          )),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text(modelitem.status)),
                        ),
                      ),
                    ]),
                ],
              )),
              ExpansionPanel(
              isExpanded: _expanded[3],
              canTapOnHeader: true,
              headerBuilder: (BuildContext ctx, bool isExpanded) {
                return ListTile(title: Text('Assets - ${_assets.values.where((element) => element.status == "New").length} new - ${_assets.values.where((element) => element.status == "Exists").length} existing - ${_assets.values.where((element) => element.status == "Created").length} Created - ${_assets.values.where((element) => element.status == "Error").length} Errors'),
                    subtitle: ValueListenableBuilder<double>(
                        valueListenable: _assetProgress,
                        builder: (ctx, dbl, _) {
                          return LinearProgressIndicator(value: dbl);
                        }));
              },
              body: Table(
                border: TableBorder.symmetric(
                    inside: const BorderSide(width: 1.0)),
                children: [
                  const TableRow(children: [
                    TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Location")),
                    )),
                    TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Model")),
                    )),
                    TableCell(
                        child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text("Tag")),
                    )),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text("Status")),
                      ),
                    ),
                  ]),
                  for(var assetitem in _assets.values)
                    TableRow(children: [
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text(assetitem.value.roomId)),
                          )),
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text("${assetitem.value.model?.name ?? ''} - ${assetitem.value.model?.manufacturer?.name ?? ''}")),
                          )),
                      TableCell(
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(child: Text(assetitem.value.assetTags.first.tagId)),
                          )),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: Text(assetitem.status)),
                        ),
                      ),
                    ]),
                ],
              ))
            ]))
      ]),
    );
  }
}
