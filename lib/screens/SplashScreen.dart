import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:upgrader/upgrader.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAndroidUpdateHandled = false;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      _handleAndroidUpdate();
    } else if (Platform.isIOS) {
      // iOS: Wait 2 seconds, then check login (upgrader shows inside build)
      Future.delayed(Duration(seconds: 2), _checkLoginAndNavigate);
    }
  }

  // ANDROID: Show custom update dialog before forcing update
  Future<void> _handleAndroidUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        _showUpdateDialog();
      } else {
        _checkLoginAndNavigate();
      }
    } catch (e) {
      print('In-app update check failed: $e');
      _checkLoginAndNavigate();
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text(
            'A new version is available. Would you like to update now?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // dismiss dialog
              _checkLoginAndNavigate(); // skip update
            },
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _performAndroidUpdate();
            },
            child: const Text('Update Now'),
          ),
        ],
      ),
    );
  }

  Future<void> _performAndroidUpdate() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      print('Update failed: $e');
      _checkLoginAndNavigate();
    }
  }

  // Shared navigation logic
  Future<void> _checkLoginAndNavigate() async {
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool('logged_in') ?? false;
    if (loggedIn) {
      Navigator.of(context).pushReplacementNamed('/image-upload');
    } else {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Platform.isIOS
        ? UpgradeAlert(
            child: _splashBody(),
          )
        : _splashBody();
  }

  Widget _splashBody() {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/images/mediola_launcher.png'),
      ),
    );
  }
}
