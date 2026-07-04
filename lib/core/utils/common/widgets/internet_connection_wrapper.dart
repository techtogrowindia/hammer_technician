import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:hammer_app/core/utils/common/screens/no_internet_screen.dart';

class InternetConnectionWrapper extends StatefulWidget {
  final Widget child;
  const InternetConnectionWrapper({super.key, required this.child});

  @override
  State<InternetConnectionWrapper> createState() =>
      _InternetConnectionWrapperState();
}

class _InternetConnectionWrapperState extends State<InternetConnectionWrapper> {
  bool _hasInternet = true;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      _checkConnection(results);
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _checkInitialConnection() async {
    final results = await Connectivity().checkConnectivity();
    await _checkConnection(results);
  }

  Future<void> _checkConnection(List<ConnectivityResult> results) async {
    bool hasConnection =
        results.isNotEmpty && !results.contains(ConnectivityResult.none);

    if (hasConnection) {
      // Verify actual internet access by trying a lookup
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 4));
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          if (mounted && !_hasInternet) {
            setState(() {
              _hasInternet = true;
            });
          }
          return;
        }
      } catch (_) {
        // Fall through to error state
      }
    }

    if (mounted && _hasInternet) {
      setState(() {
        _hasInternet = false;
      });
    }
  }

  void _onRetry() {
    _checkInitialConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (!_hasInternet)
          Positioned.fill(
            child: NoInternetScreen(onRetry: _onRetry),
          ),
      ],
    );
  }
}
