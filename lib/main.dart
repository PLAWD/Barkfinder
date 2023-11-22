import 'package:flutter/material.dart';
import 'package:parkfinder/register.dart';
import 'package:parkfinder/map.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Park Finder',
      theme: ThemeData(
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _username;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfff9f0de),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (from PNG)
                Image.asset('assets/logo.png'),
                SizedBox(height: 30),
                Form(
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
                      // Password Field
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        onSaved: (value) => _password = value,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _onForgotPasswordPressed,
                    child: Text('Forgot Password?'),
                  ),
                ),
                SizedBox(height: 20),
                // Log In Button
                ElevatedButton(
                  onPressed: _onLoginPressed,
                  child: Text('LOG IN'),
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xfffff7ad),
                  ),
                ),
                SizedBox(height: 20),
                // Sign Up Link
                GestureDetector(
                  onTap: _onSignUpPressed,
                  child: Text(
                      'No account? Sign up',
                      style: TextStyle(
                        color: Color(0xffffac6e),
                        decoration: TextDecoration.underline,
                      )
                  ),
                ),
                SizedBox(height: 30),
                // Powered By Text
                Text('Powered By SARSA'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> isValidLogin(String? enteredUsername, String? enteredPassword) async {
    final prefs = await SharedPreferences.getInstance();
    final savedUsername = prefs.getString('username') ?? '';
    final savedPassword = prefs.getString('password') ?? '';

    return enteredUsername == savedUsername && enteredPassword == savedPassword;
  }

  void _onLoginPressed() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      bool isValid = await isValidLogin(_username, _password);
      if (isValid) {
        // Navigate to next screen or show a success message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Successfully Logged In!'))
        );
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid Credentials!'))
        );
      }
    }
  }

  void _onForgotPasswordPressed() {
    Navigator.push(
         context, MaterialPageRoute(builder: (context) => mapPage(title: 'Map',)));
  }

  void _onSignUpPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => CreateAccountScreen()));
  }
}
