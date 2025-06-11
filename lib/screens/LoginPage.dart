import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docexaaesthetic/blocs/AuthBloc.dart';
import 'package:docexaaesthetic/blocs/AuthEvent.dart';
import 'package:docexaaesthetic/blocs/AuthState.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final VoidCallback? onCreateAccountTap;

  const LoginPage({Key? key, this.onCreateAccountTap}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _checkLoggedIn();
  }

  Future<void> _checkLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('logged_in') ?? false;
    if (loggedIn) {
      // If already logged in, go to ImageUploadScreen directly
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/image-upload');
      });
    }
  }

  Future<void> _onLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('logged_in', true);
    // You can also store user token or id here as needed
    Navigator.of(context).pushReplacementNamed('/image-upload');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) async {
          if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          } else if (state is LoginSuccess) {
            await _onLoginSuccess();
          }
        },
        builder: (context, state) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24),
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          'Login',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        SizedBox(height: 24),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'Enter valid email',
                          onSaved: (v) => _email = v ?? '',
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(_hidePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility),
                              onPressed: () => setState(
                                  () => _hidePassword = !_hidePassword),
                            ),
                          ),
                          obscureText: _hidePassword,
                          validator: (v) => v != null && v.length >= 6
                              ? null
                              : 'Password too short',
                          onSaved: (v) => _password = v ?? '',
                        ),
                        SizedBox(height: 24),
                        state is AuthLoading
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 64, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _formKey.currentState?.save();
                                    BlocProvider.of<AuthBloc>(context).add(
                                      LoginRequested(_email, _password),
                                    );
                                  }
                                },
                                child: Text('Login',
                                    style: TextStyle(fontSize: 18)),
                              ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: widget.onCreateAccountTap ??
                              () {
                                Navigator.of(context)
                                    .pushReplacementNamed('/register');
                              },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.teal,
                          ),
                          child: Text('Don\'t have an account? Create one'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
