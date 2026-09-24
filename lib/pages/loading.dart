import 'package:flutter/material.dart';
import 'package:miru/pages/home.dart';
import 'package:miru/pages/login.dart';
import 'package:miru/services/global_controller.dart';

class Loading extends StatefulWidget {
  const Loading({super.key});

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
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
  Future<void> _finishSetup() async {
    if (_needsLogin) {
      await _controller!.store.clearAll();
    }
    _controller!.user = await _controller!.repository.fetchCurrentUser();

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const Home()),
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
      return Login(onSignedIn: _finishSetup);
    }
    return Scaffold(
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
