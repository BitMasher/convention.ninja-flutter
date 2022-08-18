import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../services/inventory_service.dart';

class InventoryManifestModify extends StatefulWidget {
  final String orgId;
  final String manifestId;

  const InventoryManifestModify(
      {Key? key, required this.orgId, required this.manifestId})
      : super(key: key);

  @override
  State<InventoryManifestModify> createState() =>
      _InventoryManifestModifyState();
}

class _InventoryManifestModifyState extends State<InventoryManifestModify> {
  Manifest? _manifest;
  List<ManifestEntry> _manifestEntries = [];
  final TextEditingController _assetTagsController = TextEditingController();
  final FocusNode _assetTagsFocusNode = FocusNode();
  String? _error;
  String location = '';
  final TextEditingController _locationController = TextEditingController();
  String responsibleParty = '';
  final TextEditingController _partyController = TextEditingController();
  String extra = '';
  final TextEditingController _extraController = TextEditingController();

  @override
  void initState() {
    setupState();
    super.initState();
  }

  Future<void> setupState() async {
    if (widget.manifestId.isNotEmpty == true) {
      _manifest =
          await InventoryService.getManifest(widget.orgId, widget.manifestId);
      location = _manifest?.roomId ?? '';
      _locationController.text = location;
      responsibleParty = _manifest?.responsibleExternalParty?.name ?? '';
      _partyController.text = responsibleParty;
      extra = _manifest?.responsibleExternalParty?.extra ?? '';
      _extraController.text = extra;
      if (_manifest != null) {
        _manifestEntries = await InventoryService.getManifestEntries(
            widget.orgId, widget.manifestId);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 50.0, 0, 0),
            child: SizedBox(
              width: 300,
              height: 315,
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
                          if (_manifest?.shipDate == null)
                          TextFormField(
                              readOnly: _manifest == null || _manifest?.shipDate != null,
                              controller: _assetTagsController,
                              focusNode: _assetTagsFocusNode,
                              onFieldSubmitted: (val) async {
                                if (val.isEmpty) {
                                  _assetTagsFocusNode.requestFocus();
                                  setState(() {
                                    _error = null;
                                  });
                                  return;
                                }
                                var asset =
                                    await InventoryService.getAssetByTag(
                                        widget.orgId, val);
                                if (asset == null) {
                                  _assetTagsFocusNode.requestFocus();
                                  _assetTagsController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              _assetTagsController.text.length);
                                  setState(() {
                                    _error = "Asset tag not found";
                                  });
                                }
                                if (_manifestEntries
                                    .any((e) => e.assetId == asset!.id)) {
                                  _assetTagsController.clear();
                                  _assetTagsFocusNode.requestFocus();
                                  setState(() {
                                    _error = null;
                                  });
                                  return;
                                }
                                var entry =
                                    await InventoryService.addManifestEntry(
                                        widget.orgId,
                                        widget.manifestId,
                                        asset!.id);
                                if (entry == null) {
                                  _assetTagsController.selection =
                                      TextSelection(
                                          baseOffset: 0,
                                          extentOffset:
                                              _assetTagsController.text.length);
                                  setState(() {
                                    _error = "failed to add entry, try again";
                                  });
                                  return;
                                } else {
                                  _error = null;
                                  _assetTagsController.clear();
                                }
                                _manifestEntries =
                                    await InventoryService.getManifestEntries(
                                        widget.orgId, widget.manifestId);
                                _assetTagsFocusNode.requestFocus();
                                setState(() {});
                              },
                              autocorrect: false,
                              decoration:
                                  const InputDecoration(hintText: 'Asset Tag')),
                          TextFormField(
                            readOnly: _manifest == null || _manifest?.shipDate != null,
                            controller: _locationController,
                            decoration:
                                const InputDecoration(labelText: 'Location'),
                            onChanged: (val) {
                              location = val;
                            },
                          ),
                          TextFormField(
                            readOnly: _manifest == null || _manifest?.shipDate != null,
                            controller: _partyController,
                            decoration: const InputDecoration(
                                labelText: 'Responsible Party'),
                            onChanged: (val) {
                              responsibleParty = val;
                            },
                          ),
                          TextFormField(
                            readOnly: _manifest == null || _manifest?.shipDate != null,
                            controller: _extraController,
                            decoration:
                                const InputDecoration(labelText: 'Extra'),
                            onChanged: (val) {
                              extra = val;
                            },
                          ),
                        ]),
                      ),
                    ),
                  ]),
                  if (_manifest != null && _manifest?.shipDate == null)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                          alignment: Alignment.bottomCenter,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await InventoryService.updateManifest(
                                      widget.orgId,
                                      widget.manifestId,
                                      location,
                                      responsibleParty,
                                      extra);
                                },
                                child: const Text('Save'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  if (location.isEmpty &&
                                      responsibleParty.isEmpty &&
                                      extra.isEmpty) {
                                    setState(() {
                                      _error =
                                          "Manifest must have a destination.";
                                    });
                                    return;
                                  }
                                  await InventoryService.updateManifest(
                                      widget.orgId,
                                      widget.manifestId,
                                      location,
                                      responsibleParty,
                                      extra);

                                  var res = await InventoryService.shipManifest(
                                      widget.orgId, widget.manifestId);
                                  if (!res) {
                                    setState(() {
                                      _error = "Failed to ship manifest";
                                    });
                                    return;
                                  }
                                  context.beamToNamed(
                                      '/dashboard/${widget.orgId}/inventory/manifests');
                                },
                                child: const Text('Ship'),
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
        child: SingleChildScrollView(
            child: Table(
                border:
                    TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
                children: [
              const TableRow(children: [
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Category')),
                )),
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Model')),
                )),
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Manufacturer')),
                )),
                TableCell(
                    child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: Text('Tags')),
                )),
                TableCell(child: Text('')),
              ]),
              for (var entry in _manifestEntries)
                TableRow(children: [
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child:
                            SelectableText(entry.asset!.model!.category!.name)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child:
                        Center(child: SelectableText(entry.asset!.model!.name)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: SelectableText(
                            entry.asset!.model!.manufacturer!.name)),
                  )),
                  TableCell(
                      child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: SelectableText(entry.asset!.assetTags
                            .map((e) => e.tagId)
                            .join(', '))),
                  )),
                  if (_manifest != null && _manifest?.shipDate == null)
                    TableCell(
                        child: ElevatedButton(
                            onPressed: () async {
                              await InventoryService.deleteManifestEntry(
                                  widget.orgId, widget.manifestId, entry.id);
                              _manifestEntries =
                                  await InventoryService.getManifestEntries(
                                      widget.orgId, widget.manifestId);
                              setState(() {});
                            },
                            child: const Text('Delete'))),
                  if (_manifest == null || _manifest?.shipDate != null) const TableCell(child: Text(''))
                ])
            ])),
      )
    ]);
  }
}
