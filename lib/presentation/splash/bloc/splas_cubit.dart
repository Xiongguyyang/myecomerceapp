import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/presentation/splash/bloc/splas_state.dart';

class SplashCubit extends Cubit<SplasState> {
  SplashCubit() : super(DisplaySplash()) {
    appStarted();
  }

  void appStarted() async {
    try {
      // Wait for splash animation
      await Future.delayed(const Duration(seconds: 2));

      // Wait for Firebase to be ready and check auth state
      await Future.delayed(const Duration(milliseconds: 500));

      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        emit(Authentication());
      } else {
        emit(UnAuthentication());
      }
    } catch (e) {
      // If any error occurs, go to login
      emit(UnAuthentication());
    }
  }
}
