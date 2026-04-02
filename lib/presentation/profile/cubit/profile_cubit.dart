import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileInitial());

  Future<void> loadProfile() async {
    emit(ProfileLoading());

    // Firebase Auth is always available — use it as the guaranteed base.
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      emit(ProfileError('Not signed in'));
      return;
    }

    // Parse display name if set (e.g. "John Doe")
    final nameParts = (authUser.displayName ?? '').trim().split(' ');
    String firstName = nameParts.isNotEmpty ? nameParts.first : '';
    String lastName  = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
    String email     = authUser.email ?? '';

    // Try to enrich from Firestore — but never fail because of it.
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
    } catch (_) {
      // Firestore unavailable or rules blocked — Auth data is enough.
    }

    emit(ProfileLoaded(
      firstName: firstName,
      lastName: lastName,
      email: email,
    ));
  }

  Future<void> updateProfile({
    required String firstName,
    required String lastName,
    required String email,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('Users').doc(uid).set(
        {
          'FirstName': firstName.trim(),
          'LastName': lastName.trim(),
          'Email': email.trim(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Best-effort — update the UI regardless.
    }

    emit(ProfileLoaded(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
    ));
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}
