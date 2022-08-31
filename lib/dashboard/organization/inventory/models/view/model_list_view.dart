import 'package:convention_ninja/dashboard/organization/inventory/models/cubit/new_model_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_repository/inventory_repository.dart';

class ModelListView extends StatefulWidget {
  const ModelListView({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  State<ModelListView> createState() => _ModelListViewState();
}

class _ModelListViewState extends State<ModelListView> {
  List<Model>? _models;
  final ModelDataSource _source = ModelDataSource();

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    var models =
        context.read<ModelRepository>().getModelsCached(widget._organizationId);
    if (models != null) {
      _source._update(models);
      setState(() {
        _models = models;
      });
    }
  }

  void _sort<T>(Comparable<T> Function(Model d) getField, int columnIndex,
      bool ascending) {
    _source._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_models == null) {
      context
          .read<ModelRepository>()
          .getModels(widget._organizationId)
          .then((value) {
        _source._update(value);
        setState(() {
          _models = value;
        });
      });
    }
    return PaginatedDataTable(
      showFirstLastButtons: true,
      header: Row(children: const [
        Text('Models'),
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
                    return _ModelAlertWidget(
                        organizationId: widget._organizationId,
                        source: _source);
                  });
            },
            child: const Text('New'))
      ],
      columns: <DataColumn>[
        const DataColumn(label: Text('Id')),
        DataColumn(
            label: const Text('Name'),
            onSort: (int columnIndex, bool ascending) =>
                _sort<String>((Model c) => c.name, columnIndex, ascending)),
        DataColumn(
            label: const Text('Manufacturer'),
            onSort: (int columnIndex, bool ascending) => _sort<String>(
                (Model c) => c.manufacturer?.name ?? '',
                columnIndex,
                ascending)),
        DataColumn(
            label: const Text('Category'),
            onSort: (int columnIndex, bool ascending) => _sort<String>(
                (Model c) => c.category?.name ?? '', columnIndex, ascending)),
        const DataColumn(label: Text('')),
        const DataColumn(label: Text('')),
      ],
      source: _source,
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumnIndex,
    );
  }
}

class _ModelAlertWidget extends StatelessWidget {
  const _ModelAlertWidget(
      {super.key,
      required String organizationId,
      required ModelDataSource source,
      Model? record})
      : _organizationId = organizationId,
        _source = source,
        _record = record;

  final String _organizationId;
  final ModelDataSource _source;
  final Model? _record;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<NewModelCubit>(
        create: (_) => NewModelCubit(
            context.read<ModelRepository>(),
            _record?.name,
            _record?.manufacturerId,
            _record?.categoryId,
            _record),
        child: BlocListener<NewModelCubit, NewModelState>(
          listener: (context, state) {
            if (state.status == NewModelStatus.failure) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(SnackBar(
                    duration: const Duration(seconds: 15),
                    content: Text(state.errorMessage ??
                        'Failed to ${_record == null ? 'create' : 'update'} model')));
              Navigator.pop(context);
            } else if (state.status == NewModelStatus.success) {
              Navigator.pop(context);
            }
          },
          child: AlertDialog(
            title: _record == null
                ? const Text('New Model')
                : const Text('Edit Model'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ModelNameInput(initialValue: _record?.name),
                _ModelManufacturerInput(organizationId: _organizationId),
                _ModelCategoryInput(organizationId: _organizationId),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel')),
              Builder(builder: (context) {
                return ElevatedButton(
                    onPressed: () async {
                      var modelRepo = context.read<ModelRepository>();
                      if (_record == null) {
                        await context
                            .read<NewModelCubit>()
                            .createModel(_organizationId);
                      } else {
                        await context.read<NewModelCubit>().updateModel();
                      }
                      _source._update(await modelRepo.getModels(_organizationId,
                          skipCache: true));
                    },
                    child: const Text('Submit'));
              })
            ],
          ),
        ));
  }
}

class ModelDataSource extends DataTableSource {
  ModelDataSource();

  List<Model> _data = [];
  String _needle = '';

  @override
  DataRow getRow(int index) {
    var data = _data
        .where((e) => e.toString().toLowerCase().contains(_needle))
        .toList();
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data[index].id)),
      DataCell(SelectableText(data[index].name)),
      DataCell(SelectableText(data[index].manufacturer?.name ?? '')),
      DataCell(SelectableText(data[index].category?.name ?? '')),
      DataCell(_EditModelButton(source: this, record: data[index])),
      DataCell(_DeleteModelButton(source: this, record: data[index])),
    ]);
  }

  void _search(String value) {
    _needle = value;
    notifyListeners();
  }

  void _update(List<Model> data) {
    _data = data;
    notifyListeners();
  }

  void _sort<T>(Comparable<T> Function(Model d) getField, bool ascending) {
    _data.sort((Model a, Model b) {
      if (!ascending) {
        final Model c = a;
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

class _ModelNameInput extends StatelessWidget {
  const _ModelNameInput({super.key, String? initialValue})
      : _initialValue = initialValue;

  final String? _initialValue;

  bool _isValid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewModelCubit, NewModelState>(
        buildWhen: (previous, current) => previous.name != current.name,
        builder: (context, state) {
          return TextFormField(
            initialValue: _initialValue,
            key: const Key('newModelForm_nameInput_textField'),
            onChanged: (name) =>
                context.read<NewModelCubit>().nameChanged(name),
            keyboardType: TextInputType.name,
            decoration: InputDecoration(
                labelText: 'name',
                helperText: '',
                errorText: _isValid(state.name) ? null : 'invalid name'),
          );
        });
  }
}

class _ModelManufacturerInput extends StatelessWidget {
  const _ModelManufacturerInput({super.key, required String organizationId})
      : _organizationId = organizationId;

  final String _organizationId;

  bool _isValid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewModelCubit, NewModelState>(
        buildWhen: (previous, current) =>
            previous.manufacturerId != current.manufacturerId,
        builder: (context, state) {
          var mfgs = context
              .read<ManufacturerRepository>()
              .getManufacturersCached(_organizationId);
          if (mfgs != null) {
            return DropdownButton<String>(
              isExpanded: true,
              value: mfgs.any((e) => e.id == state.manufacturerId)
                  ? state.manufacturerId
                  : '',
              onChanged: (manufacturerId) => context
                  .read<NewModelCubit>()
                  .manufacturerIdChanged(manufacturerId ?? ''),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Manufacturer'),
                ),
                for (var mfg in mfgs)
                  DropdownMenuItem<String>(
                      value: mfg.id, child: Text(mfg.name)),
              ],
            );
          }
          return FutureBuilder<List<Manufacturer>>(
              future: context
                  .read<ManufacturerRepository>()
                  .getManufacturers(_organizationId),
              initialData: const [],
              builder: (context, snapshot) {
                return DropdownButton<String>(
                  isExpanded: true,
                  value: snapshot.requireData
                          .any((e) => e.id == state.manufacturerId)
                      ? state.manufacturerId
                      : '',
                  hint: const Text('Manufacturer'),
                  onChanged: (manufacturerId) => context
                      .read<NewModelCubit>()
                      .manufacturerIdChanged(manufacturerId ?? ''),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Manufacturer'),
                    ),
                    for (var mfg in snapshot.requireData)
                      DropdownMenuItem<String>(
                          value: mfg.id, child: Text(mfg.name)),
                  ],
                );
              });
        });
  }
}

class _ModelCategoryInput extends StatelessWidget {
  const _ModelCategoryInput({super.key, required String organizationId})
      : _organizationId = organizationId;

  final String _organizationId;

  bool _isValid(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewModelCubit, NewModelState>(
        buildWhen: (previous, current) =>
            previous.categoryId != current.categoryId,
        builder: (context, state) {
          var cats = context
              .read<CategoryRepository>()
              .getCategoriesCached(_organizationId);
          if (cats != null) {
            return DropdownButton<String>(
              isExpanded: true,
              value: cats.any((e) => e.id == state.categoryId)
                  ? state.categoryId
                  : '',
              onChanged: (categoryId) => context
                  .read<NewModelCubit>()
                  .categoryIdChanged(categoryId ?? ''),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Select One'),
                ),
                for (var cat in cats)
                  DropdownMenuItem<String>(
                      value: cat.id, child: Text(cat.name)),
              ],
            );
          }
          return FutureBuilder<List<Category>>(
              future: context
                  .read<CategoryRepository>()
                  .getCategories(_organizationId),
              initialData: const [],
              builder: (context, snapshot) {
                return DropdownButton<String>(
                  isExpanded: true,
                  value:
                      snapshot.requireData.any((e) => e.id == state.categoryId)
                          ? state.categoryId
                          : '',
                  hint: const Text('Category'),
                  onChanged: (categoryId) => context
                      .read<NewModelCubit>()
                      .categoryIdChanged(categoryId ?? ''),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Category'),
                    ),
                    for (var cat in snapshot.requireData)
                      DropdownMenuItem<String>(
                          value: cat.id, child: Text(cat.name)),
                  ],
                );
              });
        });
  }
}

class _EditModelButton extends StatelessWidget {
  const _EditModelButton(
      {super.key, required ModelDataSource source, required Model record})
      : _source = source,
        _record = record;
  final ModelDataSource _source;
  final Model _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return _ModelAlertWidget(
                    organizationId: _record.organizationId,
                    source: _source,
                    record: _record);
              });
        },
        child: const Text('Edit'));
  }
}

class _DeleteModelButton extends StatelessWidget {
  const _DeleteModelButton(
      {super.key, required ModelDataSource source, required Model record})
      : _source = source,
        _record = record;
  final ModelDataSource _source;
  final Model _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var modelRepo = context.read<ModelRepository>();
          await modelRepo.deleteModel(_record.organizationId, _record.id);
          var models = await modelRepo.getModels(_record.organizationId,
              skipCache: true);
          _source._update(models);
        },
        child: const Text('Delete'));
  }
}
