import 'package:booking_app/app.dart';
import 'package:booking_app/features/profile/presentation/profile_provider.dart';
import 'package:booking_app/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authStateProvider);

    return authAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Auth error: $e'))),
      data: (user) {
        if (user == null) return const LoginScreen();

        return const RootShell();
      },
    );
  }
}
