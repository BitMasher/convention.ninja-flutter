part of 'onboard_cubit.dart';

class OnboardState extends Equatable {
  const OnboardState({
    this.email = '',
    this.name = '',
    this.displayName = '',
  });

  final String email;
  final String name;
  final String displayName;

  @override
  List<Object?> get props => [email, name, displayName];

  OnboardState copyWith({String? email, String? name, String? displayName}) {
    return OnboardState(
        email: email ?? this.email,
        name: name ?? this.name,
        displayName: displayName ?? this.displayName);
  }
}
