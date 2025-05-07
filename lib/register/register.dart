import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:budgettracker/components/text_field.dart';
import 'package:budgettracker/services/auth.dart';
import 'package:budgettracker/components/login_button.dart';

class RegisterScreen extends StatelessWidget {
  RegisterScreen({super.key});

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
                "Register Account",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 25),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Email", style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              MyTextField(
                controller: emailController,
                hintText: "Email",
                obscureText: false,
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Password", style: TextStyle(color: Colors.grey[500])),
                  ],
                ),
              ),
              const SizedBox(height: 5),
              MyTextField(
                controller: passwordController,
                hintText: "Password",
                obscureText: true,
              ),

              const SizedBox(height: 25),

              LoginButton(
                text: "Sign Up",
                loginMethod: () async {
                  await AuthService().signUp(
                    email: emailController.text,
                    password: passwordController.text,
                    context: context,
                  );
                },
                color: Colors.black,
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account?"),
                  const SizedBox(width: 4),
                  GestureDetector(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.pushNamed(context, '/'),
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
