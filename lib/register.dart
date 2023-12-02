import 'package:flutter/material.dart';
import 'package:parkfinder/main.dart';
import 'package:shared_preferences/shared_preferences.dart';



class CreateAccountScreen extends StatefulWidget {
  @override
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _username;
  String? _email;
  String? _password;
  String? _confirmPassword;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            color: Color(0xffffbd59),
            width: double.infinity,
            height: 100.0,
            child: Center(
              child: Text(
                'Create Account',
                style: TextStyle(
                  fontSize: 32.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff737373),
                  fontFamily: 'Alice',
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Username Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) => _username = value,
                      ),
                      SizedBox(height: 20),
                      // Email Address Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value) => _email = value,
                      ),
                      SizedBox(height: 20),
                      // Password Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onSaved: (value) => _password = value,
                      ),
                      SizedBox(height: 20),
                      // Confirm Password Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onSaved: (value) => _confirmPassword = value,
                      ),
                      SizedBox(height: 40),
                      // Next Button
                      ElevatedButton(
                        onPressed: _onNextPressed,
                        child: Text('SUBMIT',
                            style: TextStyle(
                              color: Colors.white,
                            )
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xffffbd59),
                          padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                          textStyle: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      // Login Link
                      GestureDetector(
                        onTap: _onLoginPressed,
                        child: Text(
                          'Already have an account? Log in',
                          style: TextStyle(
                            color: Color(0xffffac6e),
                            decoration: TextDecoration.underline,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAccountCreatedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
        ),
        title: Text('Account Created!'),
        actions: [
          TextButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.of(context).pop(); // close the dialog
              _onLoginPressed(); // navigate to login
            },
          ),
        ],
      ),
    );
  }

  void _onNextPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Save to shared_preferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', _username!);
      prefs.setString('email', _email!);
      prefs.setString('password', _password!);

      // Show the account created dialog
      _showAccountCreatedDialog();
    }
  }

  void _onLoginPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => MyApp()));
  }
}
