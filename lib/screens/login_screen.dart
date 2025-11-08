import 'package:flutter/material.dart';
import 'package:api_petvida03/services/api_service.dart';
import 'package:api_petvida03/screens/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    // 🔐 Login no Django REST Framework
    final loginResponse = await _apiService.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (loginResponse != null) {
      try {
        // ✅ Login bem-sucedido
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login realizado com sucesso!'),
            backgroundColor: Color.fromRGBO(76, 175, 80, 1),
          ),
        );

        // 🔔 Obtém o token FCM e envia ao Django
        final fcmToken = await _apiService.getFCMTokenAndRequestPermission();
        if (fcmToken != null) {
          await _apiService.saveFCMToken(fcmToken);
          debugPrint('✅ Token FCM registrado no servidor Django!');
        } else {
          debugPrint('⚠️ Não foi possível obter o token FCM.');
        }

        // 🏠 Redireciona para a tela inicial
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } catch (e) {
        debugPrint("Erro ao registrar FCM: $e");

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Login feito, mas falha ao registrar notificações: $e'),
            backgroundColor: Colors.orange,
          ),
        );

        // Mesmo com falha no FCM, segue para Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      // ❌ Falha no login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha no login. Verifique suas credenciais.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login PetVida'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo PetVida
            Image.asset(
              'assets/images/logo_petvida.jpg',
              height: 120,
            ),
            const SizedBox(height: 32.0), // Espaçamento entre logo e campos
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Nome de usuário',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Senha',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24.0),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text('Entrar'),
                  ),
          ],
        ),
      ),
    );
  }
}
