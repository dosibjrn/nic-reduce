import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  Future<void> _handleGoogleSignIn(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    await authService.signInWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to Nicotine Reducer'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleGoogleSignIn(context),
          child: const Text('Sign in with Google'),
        ),
      ),
    );
  }
}
