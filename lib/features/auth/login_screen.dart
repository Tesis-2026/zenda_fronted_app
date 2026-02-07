import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      final success = await auth.login(_emailController.text.trim(), _passwordController.text.trim());
                      setState(() => _isLoading = false);
                      if (success) {
                        // Con GoRouter usamos context.go
                        context.go('/dashboard');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Credenciales inválidas')));
                      }
                    },
              child: _isLoading ? const CircularProgressIndicator() : const Text('Ingresar'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                // TODO: navegar a registro
              },
              child: const Text('Registrarme'),
            ),
            const SizedBox(height: 24),
            const Text('Zenda no conecta con bancos. Tus datos son privados.'),
          ],
        ),
      ),
    );
  }
}
