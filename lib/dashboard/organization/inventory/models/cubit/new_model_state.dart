part of 'new_model_cubit.dart';

enum NewModelStatus {
  pure,
  inProgress,
  success,
  failure,
}

@immutable
class NewModelState extends Equatable {
  const NewModelState(
      {this.name = '',
      this.manufacturerId = '',
      this.categoryId = '',
      this.status = NewModelStatus.pure,
      this.model,
      this.errorMessage = ''});

  final String name;
  final String manufacturerId;
  final String categoryId;
  final NewModelStatus status;
  final Model? model;
  final String? errorMessage;

  @override
  List<Object> get props => [name, manufacturerId, categoryId, status];

  NewModelState copyWith(
      {NewModelStatus? status,
      String? name,
      String? manufacturerId,
      String? categoryId,
      Model? model,
      String? errorMessage}) {
    return NewModelState(
        status: status ?? this.status,
        name: name ?? this.name,
        manufacturerId: manufacturerId ?? this.manufacturerId,
        categoryId: categoryId ?? this.categoryId,
        model: model ?? this.model,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
