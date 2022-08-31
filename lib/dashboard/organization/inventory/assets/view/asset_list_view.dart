import 'package:convention_ninja/dashboard/organization/inventory/models/cubit/new_model_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_repository/inventory_repository.dart';

class AssetListView extends StatefulWidget {
  const AssetListView({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  State<AssetListView> createState() => _AssetListViewState();
}

class _AssetListViewState extends State<AssetListView> {
  List<Asset>? _assets;
  final AssetDataSource _source = AssetDataSource();

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    var assets =
        context.read<AssetRepository>().getAssetsCached(widget._organizationId);
    if (assets != null) {
      _source._update(assets);
      setState(() {
        _assets = assets;
      });
    }
  }

  @override
  void didUpdateWidget(covariant AssetListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    context
        .read<AssetRepository>()
        .getAssets(widget._organizationId, skipCache: true)
        .then((value) => _source._update(value));
  }

  void _sort<T>(Comparable<T> Function(Asset d) getField, int columnIndex,
      bool ascending) {
    _source._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_assets == null) {
      context
          .read<AssetRepository>()
          .getAssets(widget._organizationId)
          .then((value) {
        _source._update(value);
        setState(() {
          _assets = value;
        });
      });
    }
    return PaginatedDataTable(
      showFirstLastButtons: true,
      header: Row(children: const [
        Text('Assets'),
      ]),
      actions: [
        SizedBox(
            width: 200,
            child: TextField(
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: (value) => _source._search(value),
            )),
        ElevatedButton(
            onPressed: () {
              context.go(
                  '/dashboard/${widget._organizationId}/inventory/assets/new');
            },
            child: const Text('New'))
      ],
      columns: <DataColumn>[
        const DataColumn(label: Text('Id')),
        DataColumn(
            label: const Text('Location'),
            onSort: (int columnIndex, bool ascending) =>
                _sort<String>((Asset c) => c.roomId, columnIndex, ascending)),
        DataColumn(
            label: const Text('Tags'),
            onSort: (int columnIndex, bool ascending) => _sort<String>(
                (Asset c) => c.assetTags.map((e) => e.tagId).join(','),
                columnIndex,
                ascending)),
        DataColumn(
            label: const Text('Model'),
            onSort: (int columnIndex, bool ascending) => _sort<String>(
                (Asset c) => c.model?.name ?? '', columnIndex, ascending)),
        DataColumn(
            label: const Text('Manufacturer'),
            onSort: (int columnIndex, bool ascending) => _sort<String>(
                (Asset c) => c.model?.manufacturer?.name ?? '',
                columnIndex,
                ascending)),
        DataColumn(
            label: const Text('Category'),
            onSort: (int columnIndex, bool ascending) => _sort<String>(
                (Asset c) => c.model?.category?.name ?? '',
                columnIndex,
                ascending)),
        const DataColumn(label: Text('')),
        const DataColumn(label: Text('')),
      ],
      source: _source,
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumnIndex,
    );
  }
}

class AssetDataSource extends DataTableSource {
  AssetDataSource();

  List<Asset> _data = [];
  String _needle = '';

  @override
  DataRow getRow(int index) {
    var data = _data
        .where((e) => e.toString().toLowerCase().contains(_needle))
        .toList();
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data[index].id)),
      DataCell(SelectableText(data[index].roomId)),
      DataCell(
          SelectableText(data[index].assetTags.map((e) => e.tagId).join(','))),
      DataCell(SelectableText(data[index].model?.name ?? '')),
      DataCell(SelectableText(data[index].model?.manufacturer?.name ?? '')),
      DataCell(SelectableText(data[index].model?.category?.name ?? '')),
      DataCell(_EditAssetButton(source: this, record: data[index])),
      DataCell(_DeleteAssetButton(source: this, record: data[index])),
    ]);
  }

  void _search(String value) {
    _needle = value;
    notifyListeners();
  }

  void _update(List<Asset> data) {
    _data = data;
    notifyListeners();
  }

  void _sort<T>(Comparable<T> Function(Asset d) getField, bool ascending) {
    _data.sort((Asset a, Asset b) {
      if (!ascending) {
        final Asset c = a;
        a = b;
        b = c;
      }
      final Comparable<T> aValue = getField(a);
      final Comparable<T> bValue = getField(b);
      return Comparable.compare(aValue, bValue);
    });
    notifyListeners();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _data
      .where((e) => e.toString().toLowerCase().contains(_needle))
      .toList()
      .length;

  @override
  int get selectedRowCount => 0;
}

class _EditAssetButton extends StatelessWidget {
  const _EditAssetButton(
      {super.key, required AssetDataSource source, required Asset record})
      : _source = source,
        _record = record;
  final AssetDataSource _source;
  final Asset _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          context.go(
              '/dashboard/${_record.organizationId}/inventory/assets/${_record.id}');
        },
        child: const Text('Edit'));
  }
}

class _DeleteAssetButton extends StatelessWidget {
  const _DeleteAssetButton(
      {super.key, required AssetDataSource source, required Asset record})
      : _source = source,
        _record = record;
  final AssetDataSource _source;
  final Asset _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var assetRepo = context.read<AssetRepository>();
          await assetRepo.deleteAsset(_record.organizationId, _record.id);
          var assets = await assetRepo.getAssets(_record.organizationId,
              skipCache: true);
          _source._update(assets);
        },
        child: const Text('Delete'));
  }
}
