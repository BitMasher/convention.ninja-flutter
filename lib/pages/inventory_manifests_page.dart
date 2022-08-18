import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import '../services/inventory_service.dart';

class InventoryManifestsPage extends StatelessWidget {
  const InventoryManifestsPage({Key? key, required this.orgId})
      : super(key: key);
  final String orgId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ManifestsDataTable(orgId: orgId),
    );
  }
}

class ManifestsDataTable extends StatefulWidget {
  const ManifestsDataTable({
    Key? key,
    required this.orgId,
  }) : super(key: key);

  final String orgId;

  @override
  State<ManifestsDataTable> createState() => _ManifestsDataTableState();
}

class _ManifestsDataTableState extends State<ManifestsDataTable> {
  late Future<List<Manifest>> _manifests;

  @override
  void initState() {
    super.initState();
    _manifests = InventoryService.getManifests(widget.orgId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Manifest>>(
        future: _manifests,
        initialData: const [],
        builder: (context, snapshot) {
          return Table(
            border: TableBorder.symmetric(inside: const BorderSide(width: 1.0)),
            defaultColumnWidth: const IntrinsicColumnWidth(),
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
                      child: Center(child: Text('Created At')),
                    )),
                const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Center(child: Text('Destination')),
                    )
                ),
                TableCell(
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child: ElevatedButton(
                                onPressed: () async {
                                  var manifest =
                                  await InventoryService.createManifest(
                                      widget.orgId);
                                  if (manifest != null) {
                                    context.beamToNamed(
                                        "/dashboard/${widget
                                            .orgId}/inventory/manifests/${manifest
                                            .id}");
                                  }
                                },
                                child: const Text("New")))))
              ]),
              for (var entry in snapshot.data!) buildDataRow(entry, snapshot)
            ],
          );
        });
  }

  TableRow buildDataRow(Manifest entry,
      AsyncSnapshot<List<Manifest>> snapshot) {
    return TableRow(children: [
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(entry.id))),
      TableCell(
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SelectableText(entry.createdAt.toLocal().toString()))),
      TableCell(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: SelectableText('loc: ${entry.roomId ?? 'N/A'}, per: ${entry
                  .responsibleExternalParty?.name ?? 'N/A'}, ex: ${entry
                  .responsibleExternalParty?.extra}'),
            ),
          )
      ),
      TableCell(
          child:
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            ElevatedButton(
                onPressed: () async {
                  context.beamToNamed(
                      "/dashboard/${widget.orgId}/inventory/manifests/${entry
                          .id}");
                },
                child: const Text('Edit')),
            ElevatedButton(
                onPressed: () async {
                  context.beamToNamed(
                      "/dashboard/${widget.orgId}/inventory/manifests/${entry
                          .id}");
                },
                child: const Text('Ship')),
            ElevatedButton(
                onPressed: () async {
                  await InventoryService.deleteManifest(widget.orgId, entry.id);
                  setState(() {
                    _manifests = InventoryService.getManifests(widget.orgId);
                  });
                },
                child: const Text('Delete')),
          ]))
    ]);
  }
}
