import 'package:flutter/material.dart';

import 'login_page.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
            child: Container(
              alignment: Alignment.center,
              height: 600,
              //media query
              color: Colors.white,
              padding:
                  const EdgeInsets.only(top: 80, left: 16, right: 16, bottom: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/images/logo-with-duo.png",
                        width: 270,
                      ),
                      const SizedBox(
                        height: 22,
                      ),
                      SizedBox(
                        width: 280,
                        child: Text(
                          "Aprenda idiomas de graça. Agora e sempre.",
                          style: TextStyle(
                            fontSize: 26,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      const Flexible(
                        child: FractionallySizedBox(
                          heightFactor: 0.75,
                        ),
                      ),
                      _button("COMEÇAR AGORA",
                          color: Colors.lightGreen,
                          onPressed: () {},
                          colorText: Colors.white),
                      const SizedBox(
                        height: 12,
                      ),
                      _button("JÁ TENHO UMA CONTA", color: Colors.white,
                          onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const LoginPage()));
                      }, colorText: Colors.green),
                    ],
                  ),
            ),
        ),
    );
  }

  Widget _button(String text,
          {Color? color, Color? colorText, VoidCallback? onPressed}) =>
      Container(
        width: 350,
        height: 60,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(128),
            spreadRadius: 2,
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ]),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: colorText,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0, // Since container has manual shadow
          ),
          onPressed: onPressed,
          child: Text(
            text,
            style: TextStyle(
                color: colorText, fontSize: 23, fontWeight: FontWeight.bold),
          ),
        ),
      );
}
