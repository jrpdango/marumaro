import 'package:flutter/material.dart';
import 'package:marumaro/features/home/home.dart';
import 'package:marumaro/features/auth/login_page.dart';
import 'package:marumaro/core/core.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  GlobalController? _controller;
  bool _needsLogin = false;

  /// Restores the stored session, prompting the user to log in if needed.
  Future<void> _setupMALConnection() async {
    final bool authenticated = await _controller!.auth.restoreSession();
    if (!authenticated) {
      if (mounted) setState(() => _needsLogin = true);
      return;
    }
    await _finishSetup();
  }

  /// Fetches the current user and navigates to the home page.
  ///
  /// If anything fails (bad token, network error, malformed response) we drop
  /// the session and fall back to the login screen instead of leaving the user
  /// on an endless spinner.
  Future<void> _finishSetup() async {
    try {
      if (_needsLogin) {
        await _controller!.store.clearAll();
      }
      _controller!.user = await _controller!.repository.fetchCurrentUser();
    } catch (_) {
      await _controller!.auth.signOut();
      await _controller!.store.clearAll();
      _controller!.user = null;
      if (!mounted) return;
      setState(() => _needsLogin = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Could not load your profile. Please log in again."),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null) {
      _controller = GlobalControllerScope.of(context);
      _setupMALConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_needsLogin) {
      return LoginPage(onSignedIn: _finishSetup);
    }
    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
