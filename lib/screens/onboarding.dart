import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_bytes_task/screens/common.dart';
import 'package:what_bytes_task/screens/signup_screen.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  int currindex = 0;

  void nextPage() {
    if (currindex < pages.length - 1) {
      setState(() {
        currindex++;
      });
    } else {
     
      setFirstSeen();
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignUpScreen()),
          (_) => false);
    }
  }

  void setFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstSeen', false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(left: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                height: 130,
                width: 130,
                margin: const EdgeInsets.only(left: 30),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.deepPurple),
                child: const Icon(
                  Icons.check,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                pages[currindex]["title"]!,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                pages[currindex]["subtitle"]!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => buildDot(index, currindex),
              ),
            ),
            const Spacer(),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0, right: 0),
                child: GestureDetector(
                  onTap: nextPage,
                  child: Container(
                    height: MediaQuery.sizeOf(context).width / 2,
                    width: MediaQuery.sizeOf(context).width / 2,
                    padding: const EdgeInsets.only(top: 80, left: 80),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(
                              MediaQuery.sizeOf(context).width / 2)),
                      shape: BoxShape.rectangle,
                      color: Colors.deepPurple,
                    ),
                    child: const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
