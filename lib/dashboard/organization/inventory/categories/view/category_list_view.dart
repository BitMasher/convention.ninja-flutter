import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:inventory_repository/inventory_repository.dart';

class CategoryListView extends StatefulWidget {
  const CategoryListView({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  @override
  State<CategoryListView> createState() => _CategoryListViewState();
}

class _CategoryListViewState extends State<CategoryListView> {
  List<Category>? _categories;
  final CategoryDataSource _source = CategoryDataSource();

  int _sortColumnIndex = 0;
  bool _sortAscending = true;

  @override
  void initState() {
    super.initState();
    var cats = context
        .read<CategoryRepository>()
        .getCategoriesCached(widget._organizationId);
    if (cats != null) {
      _source._update(cats);
      setState(() {
        _categories = cats;
      });
    }
  }

  void _sort<T>(Comparable<T> Function(Category d) getField, int columnIndex,
      bool ascending) {
    _source._sort<T>(getField, ascending);
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_categories == null) {
      context
          .read<CategoryRepository>()
          .getCategories(widget._organizationId)
          .then((value) {
        _source._update(value);
        setState(() {
          _categories = value;
        });
      });
    }
    return PaginatedDataTable(
      header: Row(children: const [
        Text('Categories'),
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
                      title: const Text('New Category'),
                      content: TextField(
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                        onSubmitted: (value) async {
                          var catRepo = ctx.read<CategoryRepository>();
                          await catRepo.createCategory(
                              widget._organizationId, value);
                          var cats = await catRepo.getCategories(
                              widget._organizationId,
                              skipCache: true);
                          _source._update(cats);
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
            onSort: (int columnIndex, bool ascending) =>
                _sort<String>((Category c) => c.name, columnIndex, ascending)),
        const DataColumn(label: Text('')),
        const DataColumn(label: Text(''))
      ],
      source: _source,
      sortAscending: _sortAscending,
      sortColumnIndex: _sortColumnIndex,
    );
  }
}

class CategoryDataSource extends DataTableSource {
  CategoryDataSource();

  List<Category> _data = [];
  String _needle = '';

  @override
  DataRow getRow(int index) {
    var data =
        _data.where((e) => e.name.toLowerCase().contains(_needle)).toList();
    return DataRow.byIndex(index: index, cells: [
      DataCell(Text(data[index].id)),
      DataCell(SelectableText(data[index].name)),
      DataCell(_EditCategoryButton(source: this, record: data[index])),
      DataCell(_DeleteCategoryButton(source: this, record: data[index])),
    ]);
  }

  void _search(String value) {
    _needle = value;
    notifyListeners();
  }

  void _update(List<Category> data) {
    _data = data;
    notifyListeners();
  }

  void _sort<T>(Comparable<T> Function(Category d) getField, bool ascending) {
    _data.sort((Category a, Category b) {
      if (!ascending) {
        final Category c = a;
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

class _EditCategoryButton extends StatelessWidget {
  const _EditCategoryButton(
      {super.key, required CategoryDataSource source, required Category record})
      : _source = source,
        _record = record;
  final CategoryDataSource _source;
  final Category _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (ctx) {
                return AlertDialog(
                  title: const Text('Edit Category'),
                  content: TextFormField(
                    initialValue: _record.name,
                    decoration: const InputDecoration(labelText: 'Category'),
                    onFieldSubmitted: (value) async {
                      var catRepo = ctx.read<CategoryRepository>();
                      await catRepo.updateCategory(
                          _record.organizationId, _record.id, value);
                      var cats = await catRepo.getCategories(
                          _record.organizationId,
                          skipCache: true);
                      _source._update(cats);
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

class _DeleteCategoryButton extends StatelessWidget {
  const _DeleteCategoryButton(
      {super.key, required CategoryDataSource source, required Category record})
      : _source = source,
        _record = record;
  final CategoryDataSource _source;
  final Category _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var catRepo = context.read<CategoryRepository>();
          await catRepo.deleteCategory(_record.organizationId, _record.id);
          var cats = await catRepo.getCategories(_record.organizationId,
              skipCache: true);
          _source._update(cats);
        },
        child: const Text('Delete'));
  }
}
