import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_repository/inventory_repository.dart';

class ManufacturerListView extends StatefulWidget {
  const ManufacturerListView({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  State<ManufacturerListView> createState() => _ManufacturerListViewState();
}

class _ManufacturerListViewState extends State<ManufacturerListView> {
  List<Manufacturer>? _manufacturers;
  final ManufacturerDataSource _source = ManufacturerDataSource();

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    var mfgs = context
        .read<ManufacturerRepository>()
        .getManufacturersCached(widget._organizationId);
    if (mfgs != null) {
      _source._update(mfgs);
      setState(() {
        _manufacturers = mfgs;
      });
    }
  }

  void _sort<T>(Comparable<T> Function(Manufacturer d) getField,
      int columnIndex, bool ascending) {
    _source._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_manufacturers == null) {
      context
          .read<ManufacturerRepository>()
          .getManufacturers(widget._organizationId)
          .then((value) {
        _source._update(value);
        setState(() {
          _manufacturers = value;
        });
      });
    }
    return PaginatedDataTable(
      showFirstLastButtons: true,
      header: Row(children: const [
        Text('Manufacturers'),
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
              showDialog(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      title: const Text('New Manufacturer'),
                      content: TextField(
                        decoration:
                            const InputDecoration(labelText: 'Manufacturer'),
                        onSubmitted: (value) async {
                          var mfgRepo = ctx.read<ManufacturerRepository>();
                          await mfgRepo.createManufacturer(
                              widget._organizationId, value);
                          var mfgs = await mfgRepo.getManufacturers(
                              widget._organizationId,
                              skipCache: true);
                          _source._update(mfgs);
                          Navigator.pop(ctx);
                        },
                      ),
                      actions: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel')),
                      ],
                    );
                  });
            },
            child: const Text('New'))
      ],
      columns: <DataColumn>[
        const DataColumn(label: Text('Id')),
        DataColumn(
            label: const Text('Name'),
            onSort: (int columnIndex, bool ascending) => _sort<String>(
                (Manufacturer c) => c.name, columnIndex, ascending)),
        const DataColumn(label: Text('')),
        const DataColumn(label: Text('')),
      ],
      source: _source,
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumnIndex,
    );
  }
}

class ManufacturerDataSource extends DataTableSource {
  ManufacturerDataSource();

  List<Manufacturer> _data = [];
  String _needle = '';

  @override
  DataRow getRow(int index) {
    var data =
        _data.where((e) => e.name.toLowerCase().contains(_needle)).toList();
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data[index].id)),
      DataCell(SelectableText(data[index].name)),
      DataCell(_EditManufacturerButton(source: this, record: data[index])),
      DataCell(_DeleteManufacturerButton(source: this, record: data[index])),
    ]);
  }

  void _search(String value) {
    _needle = value;
    notifyListeners();
  }

  void _update(List<Manufacturer> data) {
    _data = data;
    notifyListeners();
  }

  void _sort<T>(
      Comparable<T> Function(Manufacturer d) getField, bool ascending) {
    _data.sort((Manufacturer a, Manufacturer b) {
      if (!ascending) {
        final Manufacturer c = a;
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
      .where((e) => e.name.toLowerCase().contains(_needle))
      .toList()
      .length;

  @override
  int get selectedRowCount => 0;
}

class _EditManufacturerButton extends StatelessWidget {
  const _EditManufacturerButton(
      {super.key,
      required ManufacturerDataSource source,
      required Manufacturer record})
      : _source = source,
        _record = record;
  final ManufacturerDataSource _source;
  final Manufacturer _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('Edit Manufacturer'),
                  content: TextFormField(
                    initialValue: _record.name,
                    decoration:
                        const InputDecoration(labelText: 'Manufacturer'),
                    onFieldSubmitted: (value) async {
                      var mfgRepo = ctx.read<ManufacturerRepository>();
                      await mfgRepo.updateManufacturer(
                          _record.organizationId, _record.id, value);
                      var mfgs = await mfgRepo.getManufacturers(
                          _record.organizationId,
                          skipCache: true);
                      _source._update(mfgs);
                      Navigator.pop(ctx);
                    },
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Cancel')),
                  ],
                );
              });
        },
        child: const Text('Edit'));
  }
}

class _DeleteManufacturerButton extends StatelessWidget {
  const _DeleteManufacturerButton(
      {super.key,
      required ManufacturerDataSource source,
      required Manufacturer record})
      : _source = source,
        _record = record;
  final ManufacturerDataSource _source;
  final Manufacturer _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var mfgRepo = context.read<ManufacturerRepository>();
          await mfgRepo.deleteManufacturer(_record.organizationId, _record.id);
          var mfgs = await mfgRepo.getManufacturers(_record.organizationId,
              skipCache: true);
          _source._update(mfgs);
        },
        child: const Text('Delete'));
  }
}
