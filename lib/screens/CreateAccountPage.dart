import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:docexaaesthetic/blocs/AuthBloc.dart';
import 'package:docexaaesthetic/blocs/AuthEvent.dart';
import 'package:docexaaesthetic/blocs/AuthState.dart';

class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({Key? key}) : super(key: key);

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  bool _hidePassword = true;
  void _showMessage(String message, bool isError) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: Duration(seconds: isError ? 4 : 2),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthFailure) {
            _showMessage(state.error, true);
          } else if (state is CreateAccountSuccess) {
            if (state.response.status) {
              _showMessage(state.response.message, false);

              // Wait for the message to be shown before navigating
              Future.delayed(Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              });
            } else {
              _showMessage(state.response.message, true);
            }
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Create Account',
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
                          enabled: state is! AuthLoading,
                          decoration: InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) => v != null && v.isNotEmpty
                              ? null
                              : 'Enter your name',
                          onSaved: (v) => _name = v ?? '',
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          enabled: state is! AuthLoading,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v != null && v.contains('@')
                              ? null
                              : 'Enter valid email',
                          onSaved: (v) => _email = v ?? '',
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          enabled: state is! AuthLoading,
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
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                            ? Center(
                                child: Column(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(height: 16),
                                    Text(
                                      'Creating your account...',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 64, vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24)),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    _formKey.currentState?.save();
                                    context.read<AuthBloc>().add(
                                          CreateAccountRequested({
                                            'name': _name,
                                            'email': _email,
                                            'password': _password,
                                          }),
                                        );
                                  }
                                },
                                child: Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                        SizedBox(height: 16),
                        TextButton(
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  Navigator.of(context)
                                      .pushReplacementNamed('/login');
                                },
                          child: Text(
                            'Already have an account? Login',
                            style: TextStyle(color: Colors.teal),
                          ),
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
