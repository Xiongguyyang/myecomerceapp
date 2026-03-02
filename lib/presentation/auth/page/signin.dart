import 'package:flutter/material.dart';
import 'package:myecomerceapp/presentation/home/pages/home_page.dart';
import 'package:myecomerceapp/presentation/auth/page/signup.dart';
import 'package:myecomerceapp/presentation/service_locator.dart';
import 'package:myecomerceapp/domain/auth/repository/atuh.dart';

class SigninPage extends StatefulWidget {
  const SigninPage({super.key});

  @override
  State<SigninPage> createState() => _SigninPageState();
}

class _SigninPageState extends State<SigninPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final result = await sl<AuthRepository>().signin(email, password);
      if (!mounted) return;
      result.fold(
        (l) {
          final message = l?.toString() ?? 'Sign in failed';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        },
        (r) {
          final message = r?.toString() ?? 'Sign in successful';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(181, 3, 51, 65),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 30),
        child: Column(
          children: [
            _SignInContent(
              context,
              emailController,
              passwordController,
              _loading,
              _signin,
            ),
          ],
        ),
      ),
    );
  }
}

// text color

TextStyle _textStyle() {
  return const TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
}

TextStyle _textStylewhite() {
  return const TextStyle(color: Colors.white);
}

Widget _SignInContent(
  BuildContext context,
  TextEditingController emailController,
  TextEditingController passwordController,
  bool loading,
  Future<void> Function() onSignin,
) {
  return (Container(
    margin: EdgeInsets.all(10),
    child: Column(
      children: [
        Text("Sign In", style: _textStyle()),
        Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomePage()),
                  );
                },
                child: Text(
                  "Editor key",
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(49, 48, 47, 47),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: TextField(
                  cursorColor: const Color.fromARGB(255, 219, 46, 250),
                  style: _textStylewhite(),
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    labelStyle: const TextStyle(color: Colors.white),
                    border: OutlineInputBorder(),
                    fillColor: Colors.amber,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 57, 57, 57),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),

              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(49, 48, 47, 47),
                  borderRadius: BorderRadius.circular(7),
                ),

                child: TextField(
                  cursorColor: const Color.fromARGB(255, 219, 46, 250),
                  style: _textStylewhite(),
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: "Password",
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: const Color.fromARGB(255, 57, 57, 57),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                    ),

                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              loading
                  ? const CircularProgressIndicator()
                  : Container(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        onPressed: onSignin,
                        child: const Text(
                          "Sign In",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
              SizedBox(height: 100),
              Container(child: _createAccounttextbutton(context)),
            ],
          ),
        ),
      ],
    ),
  ));
}

Widget _createAccounttextbutton(BuildContext context) {
  return (Container(
    margin: EdgeInsets.all(10),
    alignment: Alignment.center,
    child: Column(
      children: [
        _textdonhaveaccount(),
        TextButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const SignupPage()),
            );
          },
          child: Text(
            "Create Account",
            style: TextStyle(color: const Color.fromARGB(205, 255, 238, 3)),
          ),
        ),
      ],
    ),
  ));
}

Widget _textdonhaveaccount() {
  return (Text("Don't have an account?", style: _textStylewhite()));
}
