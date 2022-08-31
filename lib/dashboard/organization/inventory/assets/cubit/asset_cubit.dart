import 'dart:core';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:inventory_repository/inventory_repository.dart';

part 'asset_state.dart';

class AssetCubit extends Cubit<AssetState> {
  AssetCubit(this.organizationId, this.assetRepository, Asset? asset)
      : super(AssetState(
            serialNumber: asset?.serialNumber ?? '',
            manufacturerId: asset?.model?.manufacturerId ?? '',
            modelId: asset?.modelId ?? '',
            assetTags: asset?.assetTags ?? [],
            asset: asset));
  final String organizationId;
  final AssetRepository assetRepository;

  void assetTagChanged(String value) {
    emit(state.copyWith(
        assetTag: value, errorMessage: '', status: AssetStatus.inProgress));
  }

  void serialNumberChanged(String value) {
    emit(state.copyWith(
        serialNumber: value, errorMessage: '', status: AssetStatus.inProgress));
  }

  void manufacturerIdChanged(String value) {
    emit(state.copyWith(
        manufacturerId: value,
        errorMessage: '',
        status: AssetStatus.inProgress));
  }

  void modelIdChanged(String value) {
    emit(state.copyWith(
        modelId: value, errorMessage: '', status: AssetStatus.inProgress));
  }

  void assetChanged(Asset asset) {
    emit(state.copyWith(asset: asset));
  }

  void addAssetTag() {
    emit(state.copyWith(assetTag: '', assetTags: [
      AssetTag('', DateTime.now(), DateTime.now(), state.assetTag, '',
          organizationId),
      ...state.assetTags
    ]));
  }

  void removeAssetTag(String tagId) {
    emit(state.copyWith(assetTags: [
      for (var tag in state.assetTags)
        if (tag.tagId != tagId) tag,
    ]));
  }

  Future<void> saveAsset() async {
    if (state.modelId.isEmpty) {
      emit(state.copyWith(
          errorMessage: 'Must select a model', status: AssetStatus.failure));
    } else if (state.asset == null) {
      var res = await assetRepository.createAsset(organizationId, state.modelId,
          state.serialNumber, state.assetTags.map((e) => e.tagId).toList());
      if (res == null) {
        emit(state.copyWith(
            errorMessage: 'Failed to create asset',
            status: AssetStatus.failure));
      } else {
        emit(state.copyWith(errorMessage: '', status: AssetStatus.success));
      }
    } else {
      if (state.modelId != state.asset!.modelId ||
          state.serialNumber != state.asset!.serialNumber ||
          !listEquals(state.assetTags.map((e) => e.tagId).toList(),
              state.asset!.assetTags.map((e) => e.tagId).toList())) {
        var res = await assetRepository.updateAsset(
            organizationId, state.asset!.id,
            modelId: state.modelId, serialNumber: state.serialNumber);
        if (res == null) {
          emit(state.copyWith(
              errorMessage: 'Failed to update asset',
              status: AssetStatus.failure));
        } else {
          var del = state.asset!.assetTags
              .where((e) => !state.assetTags.any((t) => t.tagId == e.tagId))
              .where((e) => e.id.isNotEmpty)
              .toList();
          var add = state.assetTags
              .where(
                  (e) => !state.asset!.assetTags.any((t) => t.tagId == e.tagId))
              .toList();
          for (var delTag in del) {
            if (!await assetRepository.deleteAssetBarcode(
                organizationId, state.asset!.id, delTag.id, delTag.tagId)) {
              emit(state.copyWith(
                  errorMessage: 'Failed to delete asset tag',
                  status: AssetStatus.failure));
              return;
            }
          }
          for (var addTag in add) {
            if (await assetRepository.createAssetBarcode(
                    organizationId, state.asset!.id, addTag.tagId) ==
                null) {
              emit(state.copyWith(
                  errorMessage: 'Failed to add asset tag, might be in use',
                  status: AssetStatus.failure));
              return;
            }
          }
          emit(state.copyWith(errorMessage: '', status: AssetStatus.success));
        }
      }
    }
  }
}
