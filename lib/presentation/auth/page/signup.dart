import 'package:flutter/material.dart';
import 'package:myecomerceapp/presentation/auth/page/signin.dart';
import 'package:myecomerceapp/data/auth/models/user_creation_req.dart';
import 'package:myecomerceapp/presentation/service_locator.dart';
import 'package:myecomerceapp/domain/auth/repository/atuh.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
  _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final lastName = _lastNameController.text.trim();
    if (name.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    setState(() => _loading = true);

    // The backend model expects FirstName and LastName - put full name into FirstName and leave LastName empty
    final userReq = UserCreationReq(
      FirstName: name,
      LastName: lastName,
      Email: email,
      Password: password,
    );

    try {
      final result = await sl<AuthRepository>().signup(userReq);
      if (!mounted) return;

      result.fold((l) {
        // left -> error
        final message = l?.toString() ?? 'Sign up failed';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
      }, (r) {
        final message = r?.toString() ?? 'Sign up successful';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
        // After successful sign up, navigate to sign in page
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SigninPage()));
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(181, 3, 51, 65),
        centerTitle: false,
        leading: IconButton(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SigninPage()),
            );
          },
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Column(children: [
          Text('Sign Up', style: _textStyle()),
          const SizedBox(height: 16),

          _buildTextField(controller: _nameController, label: 'First name'),
          const SizedBox(height: 12),
          _buildTextField(controller: _lastNameController, label: 'Last name'),
          const SizedBox(height: 12),
          _buildTextField(controller: _emailController, label: 'Email', keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildTextField(controller: _passwordController, label: 'Password', obscureText: true),
          const SizedBox(height: 28),

          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 232, 232, 232),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
                  ),
                  onPressed: _signup,
                  child: const Text('Sign Up', style: TextStyle(color: Color.fromARGB(255, 0, 0, 0))),
                ),
        ]),
      ),
      backgroundColor: const Color.fromARGB(181, 3, 51, 65),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(49, 48, 47, 47),
        borderRadius: BorderRadius.circular(7),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        cursorColor: const Color.fromARGB(255, 219, 46, 250),
        decoration: InputDecoration(
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          border: const OutlineInputBorder(),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

TextStyle _textStyle() {
  return const TextStyle(
    color: Colors.white,
    fontSize: 30,
    fontWeight: FontWeight.bold,
  );
}
