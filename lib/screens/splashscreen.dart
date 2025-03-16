import 'package:flutter/material.dart';
import 'package:sole_mate/screens/authentication/signup.dart';


class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xff07B0F2).withOpacity(0.60),
                  const Color(0xff5BCCD9).withOpacity(0.40),
                ],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: constraints.maxHeight * 0.1,
                horizontal: constraints.maxWidth * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Find Your",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.1,
                      fontFamily: "Montserrat",
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png', // Ensure your logo image path is correct
                      width: constraints.maxWidth * 0.8,
                      height: constraints.maxHeight * 0.4,
                    ),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.02),
                  Text(
                    "SoleMate",
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.09,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async {
                      // Navigate to the appropriate screen based on local storage
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Center(
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}
