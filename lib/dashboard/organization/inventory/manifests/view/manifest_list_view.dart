import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_repository/inventory_repository.dart';

class ManifestListView extends StatelessWidget {
  ManifestListView({super.key, required String organizationId}) : _organizationId = organizationId;
  final String _organizationId;

  final ManifestDataSource _source = ManifestDataSource();

  @override
  Widget build(BuildContext context) {
    context.read<ManifestRepository>().getManifests(_organizationId).then((value) => _source._update(value));
    return PaginatedDataTable(
      source: _source,
      header: Row(
        children: const [
          Text('Manifests')
        ]
      ),
      actions: [
        ElevatedButton(
            onPressed: () async {
              var manifest = await context.read<ManifestRepository>().createManifest(_organizationId);
              if(manifest != null) {
                context.go(
                    '/dashboard/$_organizationId/inventory/manifests/${manifest.id}');
              } else {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    const SnackBar(
                      content: Text('Failed to create manifest'),
                    ),
                  );
              }
            },
            child: const Text('New'))
      ],
      columns: const [
        DataColumn(label: Text('Id')),
        DataColumn(label: Text('Created At')),
        DataColumn(label: Text('Destination')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
        DataColumn(label: Text('')),
      ],
    );
  }
}

class ManifestDataSource extends DataTableSource {
  ManifestDataSource();

  List<Manifest> _data = [];

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(_data[index].id)),
      DataCell(SelectableText(_data[index].createdAt.toLocal().toString())),
      DataCell(
          SelectableText('loc: ${_data[index].roomId ?? 'N/A'}, per: ${_data[index]
              .responsibleExternalParty?.name ?? 'N/A'}, ex: ${_data[index]
              .responsibleExternalParty?.extra}')),
      DataCell(_EditManifestButton(source: this, record: _data[index])),
      DataCell(_ShipManifestButton(source: this, record: _data[index])),
      DataCell(_DeleteManifestButton(source: this, record: _data[index])),
    ]);
  }

  void _update(List<Manifest> data) {
    _data = data;
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data.length;

  @override
  int get selectedRowCount => 0;
}


class _EditManifestButton extends StatelessWidget {
  const _EditManifestButton(
      {super.key, required ManifestDataSource source, required Manifest record})
      : _source = source,
        _record = record;
  final ManifestDataSource _source;
  final Manifest _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          context.go(
              '/dashboard/${_record.organizationId}/inventory/manifests/${_record.id}');
        },
        child: const Text('Edit'));
  }
}


class _ShipManifestButton extends StatelessWidget {
  const _ShipManifestButton(
      {super.key, required ManifestDataSource source, required Manifest record})
      : _source = source,
        _record = record;
  final ManifestDataSource _source;
  final Manifest _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var manifestRepo = context.read<ManifestRepository>();
          await manifestRepo.shipManifest(_record.organizationId, _record.id);
          var manifests = await manifestRepo.getManifests(_record.organizationId);
          _source._update(manifests);
        },
        child: const Text('Ship'));
  }
}

class _DeleteManifestButton extends StatelessWidget {
  const _DeleteManifestButton(
      {super.key, required ManifestDataSource source, required Manifest record})
      : _source = source,
        _record = record;
  final ManifestDataSource _source;
  final Manifest _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var manifestRepo = context.read<ManifestRepository>();
          await manifestRepo.deleteManifest(_record.organizationId, _record.id);
          var manifests = await manifestRepo.getManifests(_record.organizationId);
          _source._update(manifests);
        },
        child: const Text('Delete'));
  }
}
