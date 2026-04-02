import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  static const _imagePathKey   = 'flexy_profile_image';
  static const _avatarIndexKey = 'flexy_profile_avatar';

  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());

    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      emit(ProfileError('Not signed in'));
      return;
    }

    final nameParts = (authUser.displayName ?? '').trim().split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String lastName  = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    String email     = authUser.email ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(authUser.uid)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        firstName = (data['FirstName'] as String?)?.trim().isNotEmpty == true
            ? data['FirstName'] as String
            : firstName;
        lastName  = (data['LastName'] as String?)?.trim().isNotEmpty == true
            ? data['LastName'] as String
            : lastName;
        email     = (data['Email'] as String?)?.trim().isNotEmpty == true
            ? data['Email'] as String
            : email;
      }
    } catch (_) {}

    final prefs       = await SharedPreferences.getInstance();
    final imagePath   = prefs.getString(_imagePathKey);
    final avatarIndex = prefs.getInt(_avatarIndexKey) ?? -1;

    emit(ProfileLoaded(
      firstName: firstName,
      lastName: lastName,
      email: email,
      imagePath: imagePath,
      avatarIndex: avatarIndex,
    ));
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
  }) async {
    final current = state is ProfileLoaded ? state as ProfileLoaded : null;
    final uid     = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      try {
        await FirebaseFirestore.instance.collection('Users').doc(uid).set(
          {
            'FirstName': firstName.trim(),
            'LastName':  lastName.trim(),
          },
          SetOptions(merge: true),
        );
        await FirebaseAuth.instance.currentUser?.updateDisplayName(
          '${firstName.trim()} ${lastName.trim()}'.trim(),
        );
      } catch (_) {}
    }

    emit(ProfileLoaded(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: current?.email ?? '',
      imagePath: current?.imagePath,
      avatarIndex: current?.avatarIndex ?? -1,
    ));
  }

  Future<void> setImagePath(String path) async {
    final current = state is ProfileLoaded ? state as ProfileLoaded : null;
    final prefs   = await SharedPreferences.getInstance();
    await prefs.setString(_imagePathKey, path);
    await prefs.remove(_avatarIndexKey);

    emit(ProfileLoaded(
      firstName: current?.firstName ?? '',
      lastName: current?.lastName ?? '',
      email: current?.email ?? '',
      imagePath: path,
      avatarIndex: -1,
    ));
  }

  Future<void> setAvatar(int index) async {
    final current = state is ProfileLoaded ? state as ProfileLoaded : null;
    final prefs   = await SharedPreferences.getInstance();
    await prefs.setInt(_avatarIndexKey, index);
    await prefs.remove(_imagePathKey);

    emit(ProfileLoaded(
      firstName: current?.firstName ?? '',
      lastName: current?.lastName ?? '',
      email: current?.email ?? '',
      imagePath: null,
      avatarIndex: index,
    ));
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
