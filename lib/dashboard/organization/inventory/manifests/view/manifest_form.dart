import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_repository/inventory_repository.dart';

import '../cubit/manifest_cubit.dart';

class ManifestForm extends StatelessWidget {
  const ManifestForm(
      {super.key, required String organizationId, required String manifestId})
      : _organizationId = organizationId,
        _manifestId = manifestId;
  final String _organizationId;
  final String _manifestId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Manifest?>(
        future: context
            .read<ManifestRepository>()
            .getManifest(_organizationId, _manifestId),
        builder: (ctx, snapshot) {
          if (snapshot.hasData) {
            return BlocProvider<ManifestCubit>(
                create: (_) => ManifestCubit(
                    _organizationId,
                    context.read<ManifestRepository>(),
                    context.read<AssetRepository>(),
                    snapshot.requireData!),
                child: _ManifestFormCard(organizationId: _organizationId));
          }
          return const Text('Loading...');
        });
  }
}

class _ManifestFormCard extends StatelessWidget {
  _ManifestFormCard({super.key, required String organizationId})
      : _organizationId = organizationId;
  final String _organizationId;

  final ManifestEntryDataSource _source = ManifestEntryDataSource();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManifestCubit, ManifestState>(
        listener: (context, state) {
          if (state.status == ManifestStatus.success) {
            context.go('/dashboard/$_organizationId/inventory/manifests');
          }
        },
        child: BlocBuilder<ManifestCubit, ManifestState>(
            buildWhen: (previous, current) => false,
            builder: (ctx, state) {
              context.read<ManifestRepository>().getManifestEntries(_organizationId, state.manifest.id).then((value) => _source._update(value));
              return SingleChildScrollView(
                child: Column(children: [
                  Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 50, 0, 0),
                          child: SizedBox(
                              width: 300,
                              height: 315,
                              child: _ManifestForm(
                                  state: state, source: _source)))),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                      child:
                          PaginatedDataTable(source: _source, columns: const [
                        DataColumn(label: Text('Category')),
                        DataColumn(label: Text('Model')),
                        DataColumn(label: Text('Manufacturer')),
                        DataColumn(label: Text('Tags')),
                        DataColumn(label: Text(''))
                      ]))
                ]),
              );
            }));
  }
}

class _ManifestForm extends StatelessWidget {
  const _ManifestForm(
      {super.key,
      required ManifestState state,
      required ManifestEntryDataSource source})
      : _state = state,
        _source = source;
  final ManifestState _state;
  final ManifestEntryDataSource _source;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Stack(children: [
      const _ManifestErrorMessage(),
      Row(children: [
        SizedBox(
            width: 292,
            height: 315,
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  if (_state.manifest.shipDate == null)
                    _ManifestTagIdInput(source: _source),
                  _ManifestLocationInput(
                      disabled: _state.manifest.shipDate != null),
                  _ManifestNameInput(
                      disabled: _state.manifest.shipDate != null),
                  _ManifestExtraInput(
                      disabled: _state.manifest.shipDate != null),
                ])))
      ]),
      if (_state.manifest.shipDate == null)
        Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_state.manifest.shipDate == null)
                        _ManifestSaveButton(),
                      if (_state.manifest.shipDate == null)
                        _ManifestShipButton(),
                    ])))
    ]));
  }
}

class _ManifestSaveButton extends StatelessWidget {
  const _ManifestSaveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var cubit = context.read<ManifestCubit>();
          await cubit.saveManifest();
        },
        child: const Text('Save'));
  }
}

class _ManifestShipButton extends StatelessWidget {
  const _ManifestShipButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var cubit = context.read<ManifestCubit>();
          await cubit.shipManifest();
        },
        child: const Text('Ship'));
  }
}

class _ManifestLocationInput extends StatelessWidget {
  const _ManifestLocationInput({super.key, bool disabled = false})
      : _disabled = disabled;
  final bool _disabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManifestCubit, ManifestState>(
      buildWhen: (previous, current) => previous.roomId != current.roomId,
      builder: (context, state) {
        return TextFormField(
          readOnly: _disabled,
          key: const Key('manifestForm_locationInput_textField'),
          initialValue: state.manifest.roomId,
          onChanged: (value) =>
              context.read<ManifestCubit>().roomIdChanged(value),
          decoration:
              const InputDecoration(labelText: 'Location', hintText: ''),
        );
      },
    );
  }
}

class _ManifestNameInput extends StatelessWidget {
  const _ManifestNameInput({super.key, bool disabled = false})
      : _disabled = disabled;
  final bool _disabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManifestCubit, ManifestState>(
      buildWhen: (previous, current) => previous.name != current.name,
      builder: (context, state) {
        return TextFormField(
          readOnly: _disabled,
          key: const Key('manifestForm_nameInput_textField'),
          initialValue: state.manifest.responsibleExternalParty?.name ?? '',
          onChanged: (value) =>
              context.read<ManifestCubit>().nameChanged(value),
          decoration: const InputDecoration(
              labelText: 'Responsible Party', hintText: ''),
        );
      },
    );
  }
}

class _ManifestExtraInput extends StatelessWidget {
  const _ManifestExtraInput({super.key, bool disabled = false})
      : _disabled = disabled;
  final bool _disabled;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManifestCubit, ManifestState>(
      buildWhen: (previous, current) => previous.extra != current.extra,
      builder: (context, state) {
        return TextFormField(
          readOnly: _disabled,
          key: const Key('manifestForm_extraInput_textField'),
          initialValue: state.manifest.responsibleExternalParty?.extra ?? '',
          onChanged: (value) =>
              context.read<ManifestCubit>().extraChanged(value),
          decoration: const InputDecoration(labelText: 'Extra', hintText: ''),
        );
      },
    );
  }
}

class _ManifestTagIdInput extends StatelessWidget {
  const _ManifestTagIdInput(
      {super.key, required ManifestEntryDataSource source})
      : _source = source;
  final ManifestEntryDataSource _source;

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    var focus = FocusNode();
    return BlocBuilder<ManifestCubit, ManifestState>(
      buildWhen: (previous, current) => previous.tagId != current.tagId,
      builder: (context, state) {
        return TextFormField(
          key: const Key('manifestForm_tagIdInput_textField'),
          controller: controller,
          focusNode: focus,
          onChanged: (value) =>
              context.read<ManifestCubit>().tagIdChanged(value),
          onFieldSubmitted: (value) async {
            var entries =
                await context.read<ManifestCubit>().addManifestEntry();
            if (entries != null) {
              _source._update(entries);
              controller.text = '';
            }
            focus.requestFocus();
          },
          decoration:
              const InputDecoration(labelText: 'Asset Tag', hintText: ''),
        );
      },
    );
  }
}

class _ManifestErrorMessage extends StatelessWidget {
  const _ManifestErrorMessage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ManifestCubit, ManifestState>(
        buildWhen: (previous, current) =>
            previous.errorMessage != current.errorMessage,
        builder: (context, state) {
          if (state.errorMessage?.isNotEmpty == true) {
            return Align(
                alignment: Alignment.topCenter,
                child: SelectableText(state.errorMessage!,
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold)));
          }
          return const Text('');
        });
  }
}

class ManifestEntryDataSource extends DataTableSource {
  ManifestEntryDataSource();

  List<ManifestEntry> _data = [];

  @override
  DataRow getRow(int index) {
    return DataRow.byIndex(index: index, cells: [
      DataCell(SelectableText(_data[index].asset?.model?.category?.name ?? '')),
      DataCell(SelectableText(_data[index].asset?.model?.name ?? '')),
      DataCell(
          SelectableText(_data[index].asset?.model?.manufacturer?.name ?? '')),
      DataCell(SelectableText(
          _data[index].asset?.assetTags.map((t) => t.tagId).join(',') ?? '')),
      DataCell(_DeleteManifestEntryButton(source: this, record: _data[index])),
    ]);
  }

  void _update(List<ManifestEntry> data) {
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

class _DeleteManifestEntryButton extends StatelessWidget {
  const _DeleteManifestEntryButton(
      {super.key,
      required ManifestEntryDataSource source,
      required ManifestEntry record})
      : _source = source,
        _record = record;
  final ManifestEntryDataSource _source;
  final ManifestEntry _record;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          var manifestRepo = context.read<ManifestRepository>();
          await manifestRepo.deleteManifestEntry(
              _record.organizationId, _record.manifestId, _record.id);
          var entries = await manifestRepo.getManifestEntries(
              _record.organizationId, _record.manifestId);
          _source._update(entries);
        },
        child: const Text('Delete'));
  }
}
