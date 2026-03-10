abstract class ProfileState {}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String firstName;
  final String lastName;
  final String email;

  ProfileLoaded({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  String get initials =>
      '${firstName.isNotEmpty ? firstName[0] : ''}${lastName.isNotEmpty ? lastName[0] : ''}'
          .toUpperCase();
}

class ProfileError extends ProfileState {
  final String message;
  ProfileError(this.message);
}
