import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final Color color;
  final String text;
  final Function loginMethod;

  const LoginButton({
    super.key,
    required this.text,
    required this.color,
    required this.loginMethod,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => loginMethod(),
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color,
        ),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
