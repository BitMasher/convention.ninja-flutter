import 'package:convention_ninja/dashboard/organization/inventory/assets/cubit/asset_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:inventory_repository/inventory_repository.dart';

class AssetForm extends StatelessWidget {
  const AssetForm(
      {super.key, required String organizationId, required String assetId})
      : _organizationId = organizationId,
        _assetId = assetId;
  final String _organizationId;
  final String _assetId;

  @override
  Widget build(BuildContext context) {
    if (_assetId == 'new') {
      return BlocProvider<AssetCubit>(
          create: (_) => AssetCubit(
              _organizationId, context.read<AssetRepository>(), null),
          child: _AssetFormCard(organizationId: _organizationId));
    } else {
      return FutureBuilder<Asset?>(
          future: context
              .read<AssetRepository>()
              .getAsset(_organizationId, _assetId, skipCache: true),
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              return BlocProvider<AssetCubit>(
                  create: (_) => AssetCubit(_organizationId,
                      context.read<AssetRepository>(), snapshot.requireData),
                  child: _AssetFormCard(organizationId: _organizationId));
            } else {
              return const Text('loading...');
            }
          });
    }
  }
}

class _AssetFormCard extends StatelessWidget {
  const _AssetFormCard({super.key, required String organizationId})
      : _organizationId = organizationId;

  final String _organizationId;

  @override
  Widget build(BuildContext context) {
    return BlocListener<AssetCubit, AssetState>(
      listener: (context, state) {
        if (state.status == AssetStatus.success) {
          context.go('/dashboard/$_organizationId/inventory/assets');
        }
      },
      child: Center(
          child: SizedBox(
              width: 500,
              height: 370,
              child: Card(
                  child: Stack(children: [
                BlocBuilder<AssetCubit, AssetState>(
                  buildWhen: (previous, current) => previous.errorMessage != current.errorMessage,
                  builder: (context, state) {
                    if (state.errorMessage?.isNotEmpty == true) {
                      return Align(
                          alignment: Alignment.topCenter,
                          child: SelectableText(state.errorMessage!,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold)));
                    } else {
                      return const Text('');
                    }
                  },
                ),
                Row(children: [
                  SizedBox(
                      width: 240,
                      height: 350,
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(children: [
                            const _AssetSerialNumberInput(),
                            _AssetManufacturerInput(
                              organizationId: _organizationId,
                            ),
                            _AssetModelInput(organizationId: _organizationId)
                          ]))),
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
                              child: BlocBuilder<AssetCubit, AssetState>(
                                buildWhen: (previous, current) =>
                                    previous.assetTags.length !=
                                    current.assetTags.length,
                                builder: (context, state) {
                                  return ListView(shrinkWrap: true, children: [
                                    const _AssetTagInput(),
                                    for (var tag in state.assetTags)
                                      _AssetTagView(tag: tag)
                                  ]);
                                },
                              ))))
                ]),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.bottomRight,
                        child: _AssetSubmitButton()))
              ])))),
    );
  }
}

class _AssetManufacturerInput extends StatelessWidget {
  const _AssetManufacturerInput({super.key, required String organizationId})
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
    return BlocBuilder<AssetCubit, AssetState>(
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
                  .read<AssetCubit>()
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
                      .read<AssetCubit>()
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

class _AssetModelInput extends StatelessWidget {
  const _AssetModelInput({super.key, required String organizationId})
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
    return BlocBuilder<AssetCubit, AssetState>(
        buildWhen: (previous, current) =>
            previous.manufacturerId != current.manufacturerId ||
            previous.modelId != current.modelId,
        builder: (context, state) {
          var models =
              context.read<ModelRepository>().getModelsCached(_organizationId);
          if (models != null) {
            return DropdownButton<String>(
              isExpanded: true,
              value: models
                      .where((e) => e.manufacturerId == state.manufacturerId)
                      .any((e) => e.id == state.modelId)
                  ? state.modelId
                  : '',
              onChanged: (modelId) =>
                  context.read<AssetCubit>().modelIdChanged(modelId ?? ''),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Model'),
                ),
                for (var model in models
                    .where((e) => e.manufacturerId == state.manufacturerId))
                  DropdownMenuItem<String>(
                      value: model.id, child: Text(model.name)),
              ],
            );
          }
          return FutureBuilder<List<Model>>(
              future:
                  context.read<ModelRepository>().getModels(_organizationId),
              initialData: const [],
              builder: (context, snapshot) {
                return DropdownButton<String>(
                  isExpanded: true,
                  value: snapshot.requireData
                          .where(
                              (e) => e.manufacturerId == state.manufacturerId)
                          .any((e) => e.id == state.modelId)
                      ? state.modelId
                      : '',
                  hint: const Text('Model'),
                  onChanged: (modelId) =>
                      context.read<AssetCubit>().modelIdChanged(modelId ?? ''),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Model'),
                    ),
                    for (var model in snapshot.requireData
                        .where((e) => e.manufacturerId == state.manufacturerId))
                      DropdownMenuItem<String>(
                          value: model.id, child: Text(model.name)),
                  ],
                );
              });
        });
  }
}

class _AssetSerialNumberInput extends StatelessWidget {
  const _AssetSerialNumberInput({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AssetCubit, AssetState>(
      buildWhen: (previous, current) =>
          previous.serialNumber != current.serialNumber,
      builder: (context, state) {
        return TextFormField(
          key: const Key('assetForm_serialNumberInput_textField'),
          initialValue: state.asset?.serialNumber,
          onChanged: (value) =>
              context.read<AssetCubit>().serialNumberChanged(value),
          decoration:
              const InputDecoration(labelText: 'Serial Number', hintText: ''),
        );
      },
    );
  }
}

class _AssetTagInput extends StatelessWidget {
  const _AssetTagInput({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = TextEditingController();
    var focus = FocusNode();
    return BlocBuilder<AssetCubit, AssetState>(
      buildWhen: (previous, current) => previous.assetTag != current.assetTag,
      builder: (context, state) {
        return TextFormField(
          key: const Key('assetForm_assetTagInput_textField'),
          controller: controller,
          focusNode: focus,
          onChanged: (value) =>
              context.read<AssetCubit>().assetTagChanged(value),
          onFieldSubmitted: (value) {
            context.read<AssetCubit>().addAssetTag();
            controller.text = '';
            focus.requestFocus();
          },
          decoration:
              const InputDecoration(labelText: 'Asset Tag', hintText: ''),
        );
      },
    );
  }
}

class _AssetTagView extends StatelessWidget {
  const _AssetTagView({super.key, required AssetTag tag}) : _tag = tag;
  final AssetTag _tag;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(mainAxisSize: MainAxisSize.max, children: [
          SelectableText(_tag.tagId),
          Expanded(
              child: Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                      onPressed: () {
                        context.read<AssetCubit>().removeAssetTag(_tag.tagId);
                      },
                      child: const Text('Delete'))))
        ]));
  }
}

class _AssetSubmitButton extends StatelessWidget {
  const _AssetSubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await context.read<AssetCubit>().saveAsset();
        },
        child: const Text('Save'));
  }
}
