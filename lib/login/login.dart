import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:budgettracker/components/square_tile.dart';
import 'package:budgettracker/components/text_field.dart';
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/components/login_button.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              const Icon(FontAwesomeIcons.lock, size: 100),
              const SizedBox(height: 50),
              Text(
                "Welcome back!",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 25),
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),

              const SizedBox(height: 25),

              LoginButton(
                text: "Sign in",
                loginMethod:
                    () => AuthService().signIn(
                      email: emailController.text,
                      password: passwordController.text,
                    ),
                color: Colors.black,
              ),

              const SizedBox(height: 50),

              Row(
                children: [
                  Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey[800]),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      'Or continue with',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ),
                  Expanded(
                    child: Divider(thickness: 0.5, color: Colors.grey[800]),
                  ),
                ],
              ),

              const SizedBox(height: 50),

              GestureDetector(
                onTap: () => AuthService().googleLogin(),
                child: SquareTile(imagePath: 'lib/images/google.jpeg'),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Do not have an account?"),
                  const SizedBox(width: 4),
                  GestureDetector(
                    child: Text(
                      "Register Now",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/register'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
