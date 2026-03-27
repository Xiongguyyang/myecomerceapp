import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/presentation/auth/page/signin.dart';
import 'package:myecomerceapp/presentation/splash/bloc/splas_cubit.dart';
import 'package:myecomerceapp/presentation/splash/bloc/splas_state.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashPages extends StatelessWidget {
  const SplashPages({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<SplashCubit, SplasState>(
      listener: (context, state) {
        if (state is UnAuthentication) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => SigninPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 180, 221, 255),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                _Textcontentshow(),
                Image.asset("assets/images/svg.png"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Widget _Textcontentshow() {
  return Container(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Welcome To The Best App In This Planet Earth",
          style: GoogleFonts.oswald(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}
