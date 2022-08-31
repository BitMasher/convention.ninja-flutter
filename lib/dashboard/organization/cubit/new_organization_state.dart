part of 'new_organization_cubit.dart';

enum NewOrganizationStatus {
  pure,
  inProgress,
  success,
  failure,
}

class NewOrganizationState extends Equatable {
  const NewOrganizationState(
      {this.status = NewOrganizationStatus.pure,
      this.name = '',
      this.organization,
      this.errorMessage});

  final NewOrganizationStatus status;
  final String name;
  final String? errorMessage;
  final Organization? organization;

  @override
  List<Object> get props => [status, name];

  NewOrganizationState copyWith(
      {NewOrganizationStatus? status,
      String? name,
      Organization? organization,
      String? errorMessage}) {
    return NewOrganizationState(
        status: status ?? this.status,
        name: name ?? this.name,
        organization: organization ?? this.organization,
        errorMessage: errorMessage ?? this.errorMessage);
  }
}
