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
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset("assets/images/svg.png", width: 300,),
                 _Textcontentshow(),
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
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Flex JK Shop",
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
