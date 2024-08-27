import 'dart:convert';
import 'dart:io';

import 'package:qr_earth/utils/constants.dart';
import 'package:qr_earth/utils/extensions.dart';
import 'package:qr_earth/utils/global.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final _loginFormKey = GlobalKey<FormState>();
  bool _showPassowrd = false;
  bool _isLoading = false;
  bool _userNotFound = false;
  bool _wrongPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Stack(
          children: [
            Form(
              key: _loginFormKey,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Welcome Back 👋",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Hello there, login to continue",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    TextFormField(
                      controller: _usernameController,
                      keyboardType: TextInputType.text,
                      decoration: const InputDecoration(
                        labelText: "Username or Email",
                        hintText: "Enter your username or email",
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "username or email is required";
                        }
                        if (_userNotFound) {
                          return "User not found";
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      keyboardType: TextInputType.visiblePassword,
                      obscureText: !_showPassowrd,
                      decoration: InputDecoration(
                        labelText: "Password",
                        hintText: "Enter your Password",
                        prefixIcon: const Icon(
                          Icons.numbers,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassowrd
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassowrd = !_showPassowrd;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Password is required";
                        }
                        if (_wrongPassword) {
                          return "Wrong Passoword";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            context.goNamed("signup");
                          },
                          child: const Text("Sign Up"),
                        ),
                        FilledButton(
                          onPressed: _login,
                          child: const Text("Log In"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _login() async {
    FocusManager.instance.primaryFocus?.unfocus();

    _wrongPassword = false;
    _userNotFound = false;

    // trim
    _usernameController.text = _usernameController.text.trim();
    _passwordController.text = _passwordController.text.trim();

    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool isEmail = _usernameController.text.isValidEmail;

      final response = await http.post(
        Uri.parse("${AppConfig.serverBaseUrl}${ApiRoutes.login}"),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
        body: jsonEncode({
          "username": !isEmail ? _usernameController.text : "",
          "email": isEmail ? _usernameController.text : "",
          "phone_number": "",
          "password": _passwordController.text,
        }),
      );

      if (response.statusCode == HttpStatus.ok) {
        return _loginSuccess(response.body);
      } else if (response.statusCode == HttpStatus.notFound) {
        // User not found
        setState(() {
          _userNotFound = true;
          _isLoading = false;
        });
      } else if (response.statusCode == HttpStatus.unauthorized) {
        // Wrong password
        setState(() {
          _wrongPassword = true;
          _isLoading = false;
        });
      } else {
        // Something went wrong
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "Unhandled Exception: ${response.statusCode} - ${response.body}"),
          ),
        );
      }

      _loginFormKey.currentState!.validate();
    }
  }

  void _loginSuccess(String body) async {
    Global.user.setFromJson(jsonDecode(body));

    var sharedpref = await SharedPreferences.getInstance();
    await sharedpref.setBool(SharedPrefKeys.isLoggedIn, true);
    await sharedpref.setString(SharedPrefKeys.userData, body);

    context.goNamed("home");
  }
}