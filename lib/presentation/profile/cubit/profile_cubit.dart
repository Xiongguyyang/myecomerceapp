import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/domain/auth/repository/atuh.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_state.dart';
import 'package:myecomerceapp/presentation/service_locator.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
      final result = await sl<AuthRepository>().getUser(uid, '');
      result.fold(
        (error) => emit(ProfileError(error.toString())),
        (data) {
          final map = data as Map<String, dynamic>? ?? {};
          emit(ProfileLoaded(
            firstName: map['FirstName'] ?? '',
            lastName: map['LastName'] ?? '',
            email: map['Email'] ??
                FirebaseAuth.instance.currentUser?.email ??
                '',
          ));
        },
      );
    } catch (e) {
      emit(ProfileError('Failed to load profile'));
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
  Future<void> updateProfile({
  required String firstName,
  required String lastName,
  required String email,
}) async {
  try {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    final result = await sl<AuthRepository>().updateUser(uid, {
      'FirstName': firstName,
      'LastName': lastName,
      'Email': email,
    });
    result.fold(
      (error) => emit(ProfileError(error.toString())),
      (_) => emit(ProfileLoaded(
        firstName: firstName,
        lastName: lastName,
        email: email,
      )),
    );
  } catch (e) {
    emit(ProfileError('Failed to update profile'));
  }
}
}


