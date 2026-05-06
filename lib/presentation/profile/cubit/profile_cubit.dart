import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  static const _firstNameKey   = 'flexy_first_name';
  static const _lastNameKey    = 'flexy_last_name';
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

    final prefs       = await SharedPreferences.getInstance();
    
    // Priority 1: SharedPreferences
    String firstName = prefs.getString(_firstNameKey) ?? '';
    String lastName  = prefs.getString(_lastNameKey) ?? '';
    String email     = authUser.email ?? '';

    // Priority 2: Firebase (if local is empty)
    if (firstName.isEmpty || lastName.isEmpty) {
      final nameParts = (authUser.displayName ?? '').trim().split(' ');
      if (firstName.isEmpty) firstName = nameParts.isNotEmpty ? nameParts.first : '';
      if (lastName.isEmpty) lastName  = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      try {
        final doc = await FirebaseFirestore.instance
            .collection('Users')
            .doc(authUser.uid)
            .get();
        if (doc.exists) {
          final data = doc.data() ?? {};
          if (firstName.isEmpty) {
            firstName = (data['FirstName'] as String?)?.trim() ?? '';
          }
          if (lastName.isEmpty) {
            lastName  = (data['LastName'] as String?)?.trim() ?? '';
          }
        }
      } catch (_) {}
    }

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

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_firstNameKey, firstName.trim());
    await prefs.setString(_lastNameKey, lastName.trim());

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

  Future<void> setImagePath(String tempPath) async {
    final current = state is ProfileLoaded ? state as ProfileLoaded : null;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = p.basename(tempPath);
      final savedImage = await File(tempPath).copy('${appDir.path}/$fileName');
      
      final prefs   = await SharedPreferences.getInstance();
      await prefs.setString(_imagePathKey, savedImage.path);
      await prefs.remove(_avatarIndexKey);

      emit(ProfileLoaded(
        firstName: current?.firstName ?? '',
        lastName: current?.lastName ?? '',
        email: current?.email ?? '',
        imagePath: savedImage.path,
        avatarIndex: -1,
      ));
    } catch (e) {
      emit(ProfileError('Failed to save image: $e'));
    }
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
