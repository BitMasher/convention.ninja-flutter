import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inventory_repository/inventory_repository.dart';

part 'manifest_state.dart';

class ManifestCubit extends Cubit<ManifestState> {
  ManifestCubit(this.organizationId, this.manifestRepository,
      this.assetRepository, Manifest manifest)
      : super(ManifestState(
            roomId: manifest.roomId ?? '',
            name: manifest.responsibleExternalParty?.name ?? '',
            extra: manifest.responsibleExternalParty?.extra ?? '',
            manifest: manifest));

  final String organizationId;
  final ManifestRepository manifestRepository;
  final AssetRepository assetRepository;

  void tagIdChanged(String value) {
    emit(state.copyWith(
        tagId: value, errorMessage: '', status: ManifestStatus.inProgress));
  }

  void roomIdChanged(String value) {
    emit(state.copyWith(
        roomId: value, errorMessage: '', status: ManifestStatus.inProgress));
  }

  void nameChanged(String value) {
    emit(state.copyWith(
        name: value, errorMessage: '', status: ManifestStatus.inProgress));
  }

  void extraChanged(String value) {
    emit(state.copyWith(
        extra: value, errorMessage: '', status: ManifestStatus.inProgress));
  }

  void manifestChanged(Manifest value) {
    emit(state.copyWith(manifest: value));
  }

  Future<List<ManifestEntry>?> addManifestEntry() async {
    if (state.tagId.isEmpty) {
      return null;
    }
    var asset =
        await assetRepository.getAssetByTag(organizationId, state.tagId);
    if (asset == null) {
      emit(state.copyWith(
          errorMessage: 'Could not find asset tag ${state.tagId}'));
      return null;
    }
    var entry = await manifestRepository.addManifestEntry(
        organizationId, state.manifest.id, asset.id);
    if (entry == null) {
      emit(state.copyWith(
          errorMessage:
              'Could not add asset ${state.tagId} for unknown reason'));
      return null;
    }
    var entries = await manifestRepository.getManifestEntries(
        organizationId, state.manifest.id);
    state.manifest.entries.clear();
    state.manifest.entries.addAll(entries);
    emit(state.copyWith(tagId: '', status: ManifestStatus.inProgress));
    return entries;
  }

  Future<void> saveManifest() async {
    var res = await manifestRepository.updateManifest(organizationId,
        state.manifest.id, state.roomId, state.name, state.extra);
    if (res == null) {
      emit(state.copyWith(
          errorMessage: 'Failed to save manifest',
          status: ManifestStatus.failure));
    } else {
      emit(state.copyWith(errorMessage: '', status: ManifestStatus.success));
    }
  }

  Future<void> shipManifest() async {
    var res = await manifestRepository.updateManifest(organizationId,
        state.manifest.id, state.roomId, state.name, state.extra);
    if (res == null) {
      emit(state.copyWith(
          errorMessage: 'Failed to save manifest',
          status: ManifestStatus.failure));
    } else {
      var shipRes = await manifestRepository.shipManifest(
          organizationId, state.manifest.id);
      if (!shipRes) {
        emit(state.copyWith(
            errorMessage: 'Failed to ship manifest',
            status: ManifestStatus.failure));
      } else {
        emit(state.copyWith(errorMessage: '', status: ManifestStatus.success));
      }
    }
  }
}
