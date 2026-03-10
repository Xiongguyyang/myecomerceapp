import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/presentation/auth/page/button_state.dart';
import 'package:myecomerceapp/presentation/splash/bloc/botton_state_cubit.dart';

class BasicReactiveButton extends StatelessWidget {
  const BasicReactiveButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BottonStateCubit, ButtonState>(
      builder: (context, state) {
        if (state is ButtonLoadingState) {
          return const CircularProgressIndicator();
        } else if (state is ButtonSuccessState) {
          return const Text("Success");
        } else if (state is ButtonErrorState) {
          return const Text("Error");
        }
        return const SizedBox.shrink();
      },
    );
  }
}
