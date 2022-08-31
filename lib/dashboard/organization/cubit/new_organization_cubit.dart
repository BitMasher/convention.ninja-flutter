import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:organization_repository/organization_repository.dart';

part 'new_organization_state.dart';

class NewOrganizationCubit extends Cubit<NewOrganizationState> {
  NewOrganizationCubit(this._organizationRepository)
      : super(const NewOrganizationState());
  final OrganizationRepository _organizationRepository;

  void nameChanged(String value) {
    emit(state.copyWith(status: NewOrganizationStatus.inProgress, name: value));
  }

  Future<void> createOrganization() async {
    try {
      var res = await _organizationRepository.create(state.name);
      if(res == null) {
        emit(state.copyWith(status: NewOrganizationStatus.failure, errorMessage: 'failed to create organization for unknow reason'));
      } else {
        emit(state.copyWith(organization: res, status: NewOrganizationStatus.success));
      }
    } on CreateOrganizationConflict catch(e) {
      emit(state.copyWith(status: NewOrganizationStatus.failure, errorMessage: e.message));
    }
  }
}
