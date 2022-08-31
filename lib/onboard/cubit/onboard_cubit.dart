import 'package:authentication_repository/authentication_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'onboard_state.dart';

class OnboardCubit extends Cubit<OnboardState> {
  OnboardCubit(this._authenticationRepository) : super(const OnboardState());

  final AuthenticationRepository _authenticationRepository;

  void emailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void nameChanged(String value) {
    emit(state.copyWith(name: value));
  }

  void displayNameChanged(String value) {
    emit(state.copyWith(displayName: value));
  }

  Future<void> onboard() async {
    await _authenticationRepository.onboard(state.name, state.email, state.displayName);
  }
}