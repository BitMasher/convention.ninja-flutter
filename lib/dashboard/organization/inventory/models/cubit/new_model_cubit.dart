import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:inventory_repository/inventory_repository.dart';
import 'package:meta/meta.dart';

part 'new_model_state.dart';

class NewModelCubit extends Cubit<NewModelState> {
  NewModelCubit(this._modelRepository, String? name, String? manufacturerId,
      String? categoryId, Model? model)
      : super(NewModelState(
            name: name ?? '',
            categoryId: categoryId ?? '',
            manufacturerId: manufacturerId ?? '',
            model: model));
  final ModelRepository _modelRepository;

  void nameChanged(String value) {
    emit(state.copyWith(status: NewModelStatus.inProgress, name: value));
  }

  void manufacturerIdChanged(String value) {
    emit(state.copyWith(
        status: NewModelStatus.inProgress, manufacturerId: value));
  }

  void categoryIdChanged(String value) {
    emit(state.copyWith(status: NewModelStatus.inProgress, categoryId: value));
  }

  Future<void> createModel(String organizationId) async {
    try {
      var res = await _modelRepository.createModel(
          organizationId, state.name, state.categoryId, state.manufacturerId);
      if (res == null) {
        emit(state.copyWith(
            status: NewModelStatus.failure,
            errorMessage: 'failed to create model for unknown reason'));
      } else {
        emit(state.copyWith(model: res, status: NewModelStatus.success));
      }
    } on CreateModelConflict catch (e) {
      emit(state.copyWith(
          status: NewModelStatus.failure, errorMessage: e.message));
    }
  }

  Future<void> updateModel() async {
    try {
      var res = await _modelRepository.updateModel(
          state.model!.organizationId, state.model!.id,
          name: state.name,
          manufacturerId: state.manufacturerId,
          categoryId: state.categoryId);
      if (res == null) {
        emit(state.copyWith(
            status: NewModelStatus.failure,
            errorMessage: 'failed to update model for unknown reason'));
      } else {
        emit(state.copyWith(model: res, status: NewModelStatus.success));
      }
    } on CreateModelConflict catch (e) {
      emit(state.copyWith(
          status: NewModelStatus.failure, errorMessage: e.message));
    }
  }
}
