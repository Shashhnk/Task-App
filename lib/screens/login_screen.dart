import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:what_bytes_task/providers/auth_provider.dart';
import 'package:what_bytes_task/screens/common.dart';
import 'package:what_bytes_task/screens/task_screen.dart';

import 'signup_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

 
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  bool isEmailValid = false;
  bool isPassVisible = false;

  @override
  void initState() {
    super.initState();
    setFirstSeen();
  }
void setFirstSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstSeen', true);
  }
  void _login() async {
    if (!isEmailValid || _passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'Email is not Valid or Password is less than 6 characters')),
      );
      return;
    }
    setState(() => _isLoading = true);
    final authRepo = ref.read(authRepositoryProvider);

    try {
      await authRepo.signIn(_emailController.text, _passwordController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logged in successfully!')),
      );
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const TaskScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildEmailInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '  Email',
            style: kTextStyle.copyWith(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 3,
          ),
          TextFormField(
            style: kTextStyle.copyWith(color: Colors.black),
            controller: _emailController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (!isEmailValid) {
                return "Email is not Valid";
              }
              return null;
            },
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white),
              ),
              hintText: 'email@gmail.com!',
              hintStyle: kTextStyle.copyWith(color: Colors.black54),
            ),
            onChanged: (value) {
              setState(() {
                isEmailValid = emailValidate(value);
              });
            },
          )
        ],
      ),
    );
  }

  Widget _buildPasswordInputSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '  Password',
            style: kTextStyle.copyWith(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 3),
          TextFormField(
            obscureText: isPassVisible ? false : true,
            obscuringCharacter: '*',
            style: kTextStyle.copyWith(color: Colors.black),
            controller: _passwordController,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (value) {
              if (value!.isEmpty) {
                return 'This field is required';
              } else if (value.length < 6) {
                return 'Password must be 6 characters';
              }
              return null;
            },
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey.shade200,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: Colors.white),
              ),
              hintText: 'Enter Password',
              hintStyle: kTextStyle.copyWith(color: Colors.black54),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPassVisible = !isPassVisible;
                  });
                },
                icon: isPassVisible
                    ? const Icon(
                        Icons.visibility_outlined,
                        color: Colors.deepPurple,
                      )
                    : const Icon(
                        Icons.visibility_off_outlined,
                        color: Colors.deepPurple,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buttonGradient(String text, void Function() onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isEmailValid
                  ? Colors.deepPurple.shade800
                  : Colors.deepPurple.shade200),
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator()
                : Text(
                    text,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: sora),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Spacer(),
            Container(
              height: 130,
              width: 130,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.deepPurple),
              child: const Icon(
                Icons.check,
                size: 80,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            const Text(
              "Welcome Back!",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 50,
            ),
            _buildEmailInputSection(context),
            const SizedBox(height: 25),
            _buildPasswordInputSection(context),
            const SizedBox(height: 25),
            buttonGradient('Log In', _login),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SignUpScreen()),
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: 'Don\'t have an account?',
                      style: TextStyle(
                        color: Colors.grey,
                        fontFamily: sora,
                      ),
                    ),
                    TextSpan(
                      text: '  Sign Up',
                      style: TextStyle(
                        color: Colors.deepPurple,
                        fontFamily: sora,
                        fontWeight: FontWeight.w700,
                      ),
                    )
                  ],
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
