import 'package:flutter/material.dart';
import 'package:miru/services/global_controller.dart';

class Login extends StatefulWidget {
  const Login({super.key, required this.onSignedIn});

  /// Called once the user successfully authenticates.
  final Future<void> Function() onSignedIn;

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    final bool authenticated =
        await GlobalControllerScope.of(context).auth.signIn();
    if (!mounted) return;
    if (authenticated) {
      await widget.onSignedIn();
      return;
    }
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Login failed. Please try again.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Hello, and welcome to miru! To get started, log in with your MyAnimeList account.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            _busy
                ? const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  )
                : TextButton.icon(
                    onPressed: _signIn,
                    icon: Icon(Icons.login_rounded),
                    label: Text("Login to MyAnimeList"),
                  ),
          ],
        ),
      ),
    );
  }
}
