import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:noel_notes/appwrite/auth_api.dart';
import 'package:noel_notes/component/icons/unicon_icons.dart';
import 'package:noel_notes/pages/register.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final emailTextController = TextEditingController();
  final passwordTextController = TextEditingController();
  bool loading = false;

  void signIn() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircularProgressIndicator(),
            ],
          ),
        );
      },
    );

    try {
      final AuthAPI appwrite = context.read<AuthAPI>();
      appwrite.createEmailSession(
        email: emailTextController.text,
        password: passwordTextController.text,
      );
      Navigator.pop(context);
    } on AppwriteException catch (e) {
      Navigator.pop(context);
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  void showAlert({required String title, required String text}) {
    showDialog(
      context: context,
      builder: (context) {
        //FIXME: use customAlertDialog
        return AlertDialog(
          title: Text(title),
          content: Text(text),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void signInWithProvider(String provider) {
    try {
      context.read<AuthAPI>().signInWithProvider(provider: provider);
    } on AppwriteException catch (e) {
      showAlert(title: 'Login failed', text: e.message.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Unicon.arrow_left),
        ),
        title: const Text('Note Editor'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: emailTextController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordTextController,
                decoration: const InputDecoration(
                  helperText: "Password must contain 8 characters",
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  signIn();
                },
                icon: const Icon(Unicon.entry),
                label: const Text("Sign in"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text('Create Account'),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => signInWithProvider('google'),
                    icon: const Icon(Unicon.google),
                  ),
                  IconButton(
                    onPressed: () => signInWithProvider('github'),
                    icon: const Icon(Unicon.github_alt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
