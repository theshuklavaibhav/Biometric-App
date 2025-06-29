import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

void main() {
  runApp(const BiometricApp());
}

class BiometricApp extends StatelessWidget {
  const BiometricApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Biometric Login Demo',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics = false;
  String _authStatus = "Not Authenticated";
  final TextEditingController _passwordController = TextEditingController();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricSupport();
  }

  Future<void> _checkBiometricSupport() async {
    try {
      bool canAuthenticate = await auth.canCheckBiometrics;
      setState(() {
        _canCheckBiometrics = canAuthenticate;
      });
    } catch (e) {
      setState(() {
        _authStatus = "Error checking biometrics: $e";
      });
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Scan your fingerprint or face to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      setState(() {
        _isAuthenticated = authenticated;
        _authStatus =
            authenticated ? "Authenticated with Biometrics" : "Failed to Authenticate";
      });
    } catch (e) {
      setState(() {
        _authStatus = "Authentication error: $e";
      });
    }
  }

  void _fallbackLogin() {
    String password = _passwordController.text;
    if (password == "1234") {
      setState(() {
        _isAuthenticated = true;
        _authStatus = "Authenticated with Password";
      });
    } else {
      setState(() {
        _authStatus = "Incorrect Password";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Biometric Login")),
      body: _isAuthenticated
          ? const Center(
              child: Text("✅ Login Successful!",
                  style: TextStyle(fontSize: 24, color: Colors.green)))
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fingerprint, size: 80, color: Colors.teal),
                  const SizedBox(height: 20),
                  Text(
                    "Use your fingerprint or face to log in",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.login),
                    label: const Text("Login with Biometrics"),
                    onPressed: _canCheckBiometrics
                        ? _authenticateWithBiometrics
                        : null,
                  ),
                  const SizedBox(height: 20),
                  const Text("OR"),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(
                      labelText: "Enter Password (Fallback)",
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _fallbackLogin,
                    child: const Text("Login with Password"),
                  ),
                  const SizedBox(height: 20),
                  Text(_authStatus,
                      style: TextStyle(
                          color: _authStatus.contains("Authenticated")
                              ? Colors.green
                              : Colors.red)),
                ],
              ),
            ),
    );
  }
}
