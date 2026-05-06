import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/presentation/splash/bloc/splas_state.dart';

class SplashCubit extends Cubit<SplasState> {
  SplashCubit() : super(DisplaySplash()) {
    appStarted();
  }

  void appStarted() async {
    await Future.delayed(const Duration(seconds: 3, milliseconds: 500));
    emit(UnAuthentication());
  }
}
