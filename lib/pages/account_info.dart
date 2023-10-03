// ignore_for_file: library_private_types_in_public_api, always_declare_return_types

import 'package:flutter/material.dart';
import 'package:noel_notes/appwrite/auth_api.dart';
import 'package:noel_notes/component/icons/unicon_icons.dart';
import 'package:provider/provider.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late String? email;
  late String? username;
  TextEditingController usernameTextController = TextEditingController();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final AuthAPI appwrite = context.read<AuthAPI>();
    email = appwrite.email;
    username = appwrite.username;
  }

  //FIXME Names to be synced inside Flutter
  saveName() {
    final AuthAPI appwrite = context.read<AuthAPI>();
    appwrite.updateName(name: usernameTextController.text);
    const snackbar = SnackBar(content: Text('Name updated!'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  saveEmail() {
    if (emailTextController.text == "" || passwordTextController.text == "") {
      const snackbar = SnackBar(
        content: Text('Email wasn`t saved, Email or password is empty.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return null;
    }
    final AuthAPI appwrite = context.read<AuthAPI>();
    appwrite.updateEmail(
      email: emailTextController.text,
      password: passwordTextController.text,
    );
    const snackbar = SnackBar(content: Text('Email updated!'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  savePassword() {
    if (passwordTextController.text == "") {
      const snackbar =
          SnackBar(content: Text('Password wasn`t saved because it`s empty.'));
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
      return null;
    }
    final AuthAPI appwrite = context.read<AuthAPI>();
    appwrite.updatePassword(password: passwordTextController.text);
    const snackbar = SnackBar(content: Text('Password updated!'));
    ScaffoldMessenger.of(context).showSnackBar(snackbar);
  }

  void showDialogue(
    String title,
    Widget? content,
    TextEditingController controller1,
    TextEditingController controller2,
    Function function,
  ) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        scrollable: true,
        title: Text(title),
        content: content,
        actions: <Widget>[
          TextButton(
            onPressed: () {
              controller1.clear();
              Navigator.pop(context, 'Cancel');
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              function;
              controller1.clear();
              Navigator.pop(context, 'Save');
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Account'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Text(
                    "Profile",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 65,
                    width: 65,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      image: const DecorationImage(
                        image: AssetImage("assets/images/icon.png"),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        username!,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      IconButton(
                        onPressed: () {
                          showDialogue(
                            'Edit Username?',
                            TextField(
                              controller: usernameTextController,
                              decoration: const InputDecoration(
                                labelText: 'Change Name',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            usernameTextController,
                            usernameTextController,
                            saveName(),
                          );
                        },
                        icon: const Icon(Unicon.edit),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        email!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialogue(
                            'Change Email?',
                            Column(
                              children: [
                                TextField(
                                  controller: emailTextController,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                TextField(
                                  controller: passwordTextController,
                                  decoration: const InputDecoration(
                                    labelText: 'Password',
                                    border: OutlineInputBorder(),
                                  ),
                                  obscureText: true,
                                ),
                              ],
                            ),
                            emailTextController,
                            passwordTextController,
                            saveEmail(),
                          );
                        },
                        child: const Text("Change Email"),
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(),
              TextButton(
                child: const Text("Change Password"),
                onPressed: () {
                  showDialogue(
                    'Change Password?',
                    TextField(
                      controller: passwordTextController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        helperText: "Password must contain 8 characters",
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                    ),
                    passwordTextController,
                    passwordTextController,
                    savePassword(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
