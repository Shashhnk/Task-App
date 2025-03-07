import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:what_bytes_task/main.dart';
import 'package:what_bytes_task/screens/onboarding.dart';
import 'package:what_bytes_task/providers/auth_provider.dart';
import 'package:what_bytes_task/screens/task_screen.dart';
import 'login_screen.dart';

// ignore: must_be_immutable
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    bool seen = (firstSeen == null || firstSeen == true) ? true : false;

    return authState.when(
      data: (user) => user == null
          ? (seen)
              ? const Onboarding()
              :const LoginScreen()
          : const TaskScreen(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(body: Center(child: Text("Error: $error"))),
    );
  }
}
