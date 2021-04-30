import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

import '../models/http_exception.dart';

import '../widgets/password_field.dart';


enum AuthMode { Signup, Login }

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  final GlobalKey<FormState> _formKey = GlobalKey();
  final _passwordFieldKey = GlobalKey<FormFieldState<String>>();


  var _isLoading = false;

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occurred!'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      // Sign user up
      await Provider.of<AuthProvider>(context, listen: false).login(
        _authData['email'].trim(),
        _authData['password'].trim(),
      );
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'This is not a valid email address';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Could not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'Could not authenticate you. Please try again later.';
      _showErrorDialog(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.only(left: 32, right: 32),
            children: [
              Container(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 32),
                      Align(
                        child: Text('Login:', style: TextStyle(fontSize: 16)),
                        alignment: Alignment.centerLeft,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: const InputDecoration(
                          hintText: 'Nome utente',
                          labelText: 'Nome',
                        ),
                        initialValue: '',
                        keyboardType: TextInputType.text,
                        onSaved: (value) {
                          _authData['email'] = value;
                        },
                      ),
                      SizedBox(height: 16),
                      PasswordField(
                        fieldKey: _passwordFieldKey,
                        helperText: 'No more than 8 characters.',
                        labelText: 'Password',
                        onSaved: (String value) {
                          _authData['password'] = value;
                        },
                      ),
                      SizedBox(height: 16),
                      if (_isLoading)
                        CircularProgressIndicator()
                      else
                        ElevatedButton(
                            onPressed: _submit, child: Text('Accedi'))
                    ],
                  ),
                ),
              )
            ]),
      ),
    );
  }
}
