import 'dart:io';

import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../services/inventory_service.dart';

class InventoryAssetsPage extends StatelessWidget {
  const InventoryAssetsPage({Key? key, required this.orgId}) : super(key: key);
  final String orgId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AssetsDataTable(orgId: orgId),
    );
  }
}

class AssetsDataTable extends StatefulWidget {
  const AssetsDataTable({
    Key? key,
    required this.orgId,
  }) : super(key: key);

  final String orgId;

  @override
  State<AssetsDataTable> createState() => _AssetsDataTableState();
}

class _AssetsDataTableState extends State<AssetsDataTable> {
  late Future<List<Asset>> _assets;

  @override
  void initState() {
    super.initState();
    _assets = InventoryService.getAssets(widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<List<Asset>>(
          future: _assets,
          initialData: const [],
          builder: (context, snapshot) {
            return Table(
              border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
              // defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                TableRow(children: [
                  const TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Id')),
                  )),
                  const TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Center(child: Text('Location')),
                      )),
                  const TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Serial')),
                  )),
                  const TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Model')),
                  )),
                  const TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Manufacturer')),
                  )),
                  const TableCell(
                      child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: Text('Tags')),
                  )),
                  TableCell(
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: ElevatedButton(
                                  onPressed: () {
                                    context.beamToNamed(
                                        "/dashboard/${widget.orgId}/inventory/assets/new");
                                  },
                                  child: const Text("New")))))
                ]),
                for (var entry in snapshot.data!) buildDataRow(entry, snapshot)
              ],
            );
          }),
    );
  }

  TableRow buildDataRow(Asset entry, AsyncSnapshot<List<Asset>> snapshot) {
    return TableRow(children: [
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(entry.id))),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: entry.roomId.startsWith('manifest:') ? ElevatedButton(onPressed: (){context.beamToNamed('/dashboard/${widget.orgId}/inventory/manifests/${entry.roomId.substring(9)}');}, child: Text('See Manifest')) : SelectableText(entry.roomId))),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(entry.serialNumber ?? ''))),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(entry.model?.name ?? entry.modelId))),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(entry.model?.manufacturer?.name ??
                  entry.model?.manufacturerId ??
                  ''))),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(
                  entry.assetTags.map((e) => e.tagId).join(", ")))),
      TableCell(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
        ElevatedButton(onPressed: () async {
          context.beamToNamed(
              "/dashboard/${widget.orgId}/inventory/assets/${entry.id}");
        }, child: const Text('Edit')),
        ElevatedButton(
            onPressed: () async {
              await InventoryService.deleteAsset(widget.orgId, entry.id);
              setState(() {
                _assets = InventoryService.getAssets(widget.orgId);
              });
            },
            child: const Text('Delete')),
      ]))
    ]);
  }
}
