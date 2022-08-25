import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../services/inventory_service.dart';

class InventoryAssetModify extends StatefulWidget {
  final String orgId;
  final String? assetId;

  const InventoryAssetModify({Key? key, required this.orgId, this.assetId})
      : super(key: key);

  @override
  State<InventoryAssetModify> createState() => _InventoryAssetModifyState();
}

class _InventoryAssetModifyState extends State<InventoryAssetModify> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<Manufacturer> _manufacturers = [];
  List<Model> _models = [];
  List<DropdownMenuItem<String>> _filteredModels = [];
  final List<AssetTag> _assetTags = [];
  final List<AssetTag> _toDelete = [];
  final TextEditingController _assetTagsController = TextEditingController();
  final FocusNode _assetTagsFocusNode = FocusNode();
  String? _modelId;
  String? _serialNumber;

  Asset? _asset;

  String? _error;

  final TextEditingController _serialController = TextEditingController();

  @override
  void initState() {
    setupState();
    super.initState();
  }

  Future<void> setupState() async {
    _manufacturers = await InventoryService.getManufacturers(widget.orgId);
    _models = await InventoryService.getModels(widget.orgId);
    if (widget.assetId != null && widget.assetId?.isNotEmpty == true) {
      _asset = await InventoryService.getAsset(widget.orgId, widget.assetId!);
      if (_asset != null) {
        _assetTags.addAll(_asset!.assetTags);
      }
      if (_asset != null) {
        updateModels(_asset!.model!.manufacturerId);
      }
    }
    setState((){
      _serialController.text = _asset?.serialNumber ?? '';
    });
  }

  void updateModels(String mfgId) {
    _filteredModels = (_models)
        .where((e) => e.manufacturerId == mfgId)
        .map((e) => DropdownMenuItem<String>(value: e.id, child: Text(e.name)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Center(
          child: SizedBox(
        width: 500,
        height: 370,
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
                width: 240,
                height: 350,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(children: [
                    TextFormField(
                      controller: _serialController,
                      decoration:
                          const InputDecoration(hintText: 'Serial Number'),
                      onSaved: (val) {
                        _serialNumber = val;
                      },
                    ),
                    DropdownButtonFormField<String>(
                        value: _asset?.model?.manufacturerId,
                        hint: const Text("Manufacturer"),
                        onChanged: (mfgId) {
                          setState(() {
                            updateModels(mfgId!);
                          });
                        },
                        items: _manufacturers
                            .map((e) => DropdownMenuItem<String>(
                                value: e.id, child: Text(e.name)))
                            .toList()),
                    DropdownButtonFormField<String>(
                        value: _asset?.modelId,
                        hint: const Text("Model"),
                        onChanged: (_) {},
                        validator: (val) {
                          if (val == null || val.isEmpty) {
                            return "Model is required";
                          }
                          return null;
                        },
                        onSaved: (val) {
                          _modelId = val;
                        },
                        items: _filteredModels)
                  ]),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 25.0),
                child: VerticalDivider(),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: SizedBox(
                  height: 300,
                  width: 230,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ListView(shrinkWrap: true, children: [
                      TextFormField(
                          controller: _assetTagsController,
                          focusNode: _assetTagsFocusNode,
                          onFieldSubmitted: (val) {
                            _assetTagsController.clear();
                            _assetTagsFocusNode.requestFocus();
                            if (_assetTags.any((e) => e.tagId == val) ||
                                val.isEmpty) {
                              return;
                            }
                            setState(() {
                              var t = _toDelete.firstWhere(
                                  (e) => e.tagId == val,
                                  orElse: () => AssetTag(
                                      id: "",
                                      createdAt: DateTime.now(),
                                      updatedAt: DateTime.now(),
                                      tagId: val,
                                      assetId: "",
                                      organizationId: widget.orgId));
                              if (t.id.isNotEmpty) {
                                _toDelete.remove(t);
                              }
                              _assetTags.add(t);
                            });
                          },
                          autocorrect: false,
                          decoration:
                              const InputDecoration(hintText: 'Asset Tag')),
                      for (var tag in _assetTags)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(tag.tagId),
                              Expanded(
                                  child: Align(
                                      alignment: Alignment.centerRight,
                                      child: ElevatedButton(
                                          onPressed: () {
                                            if (tag.id.isNotEmpty) {
                                              _toDelete.add(tag);
                                            }
                                            setState(() {
                                              _assetTags.remove(tag);
                                            });
                                          },
                                          child: const Text('Delete'))))
                            ],
                          ),
                        ),
                    ]),
                  ),
                ),
              )
            ]),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () async {
                      _error = "";
                      if (_formKey.currentState?.validate() == false) {
                        return;
                      }
                      _formKey.currentState?.save();
                      if (widget.assetId == null ||
                          widget.assetId?.isEmpty == true) {
                        var res = await InventoryService.createAsset(
                            widget.orgId,
                            _modelId!,
                            _serialNumber,
                            _assetTags.map((e) => e.tagId).toList());
                        if (res == null) {
                          setState(() {
                            _error =
                                "Failed to save, double check barcodes are unique";
                          });
                          return;
                        }
                      } else {
                        if(_asset?.modelId != _modelId || _asset?.serialNumber != _serialNumber) {
                          var res = await InventoryService.updateAsset(
                              widget.orgId, widget.assetId!,
                              modelId:
                              _asset?.modelId != _modelId ? _modelId : null,
                              serialNumber: _asset?.serialNumber !=
                                  _serialNumber
                                  ? _serialNumber
                                  : null);
                          if (res == null) {
                            setState(() {
                              _error = "Failed to save, dunno why";
                            });
                            return;
                          }
                        }
                        for (var delTag in _toDelete) {
                          if (await InventoryService.deleteAssetBarcode(
                                  widget.orgId, widget.assetId!, delTag.id) ==
                              false) {
                            setState(() {
                              _error = "Failed to save barcodes, dunno why";
                            });
                            return;
                          }
                        }
                        for (var addTag in _assetTags) {
                          if(addTag.id.isNotEmpty) {
                            continue;
                          }
                          if (await InventoryService.createAssetBarcode(
                                  widget.orgId,
                                  widget.assetId!,
                                  addTag.tagId) ==
                              null) {
                            setState(() {
                              _error = "Failed to save barcodes, dunno why";
                            });
                            return;
                          }
                        }
                      }
                      context.beamToNamed(
                          "/dashboard/${widget.orgId}/inventory/assets");
                    },
                    child: const Text('Save'),
                  )),
            )
          ]),
        ),
      )),
    );
  }
}
