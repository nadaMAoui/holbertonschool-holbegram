import 'package:flutter/material.dart';
import 'package:holbegram/screens/login_screen.dart';
import 'package:holbegram/widgets/text_field.dart';
import 'package:holbegram/screens/upload_image_screen.dart';
import 'package:holbegram/methods/auth_methods.dart'; // Import AuthMethods

class SignUp extends StatefulWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmController =
      TextEditingController();
  bool _passwordVisible = true;

  SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  AuthMethods authMethods = AuthMethods(); // Instantiate AuthMethods

  @override
  void initState() {
    super.initState();
    widget._passwordVisible = true;
  }

  @override
  void dispose() {
    widget.emailController.dispose();
    widget.usernameController.dispose();
    widget.passwordController.dispose();
    widget.passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 28),
            const Text(
              'Holbegram',
              style: TextStyle(
                fontFamily: 'Billabong',
                fontSize: 50,
              ),
            ),
            Image.asset('assets/images/logo.webp', width: 80, height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 28),
                  const Text(
                    'Sign up to see photos and videos\nfrom your friends.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 28),
                  TextFieldInput(
                    controller: widget.emailController,
                    isPassword: false,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24), // Email input
                  TextFieldInput(
                    controller: widget.usernameController,
                    isPassword: false,
                    hintText: 'Username',
                    keyboardType: TextInputType.text,
                  ), // Username input
                  const SizedBox(height: 24),
                  TextFieldInput(
                    controller: widget.passwordController,
                    isPassword: widget._passwordVisible,
                    hintText: 'Password',
                    keyboardType: TextInputType.visiblePassword,
                  ), // Password input
                  const SizedBox(height: 24),
                  TextFieldInput(
                    controller: widget.passwordConfirmController,
                    isPassword: widget._passwordVisible,
                    hintText: 'Confirm Password',
                    keyboardType: TextInputType.visiblePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        widget._passwordVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          widget._passwordVisible = !widget._passwordVisible;
                        });
                      },
                    ),
                  ), // Confirm password input
                  // Sign Up button
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 48,
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(
                          const Color.fromARGB(218, 226, 37, 24),
                        ),
                      ),
                      // 'Sign Up' button's onPressed callback
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddPicture(
                              email: widget.emailController.text,
                              username: widget.usernameController.text,
                              password: widget.passwordController.text,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Divider(thickness: 2),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text('Have an account?'),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => LoginScreen()),
                          );
                        },
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
