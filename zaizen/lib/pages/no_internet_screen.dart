import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/login.dart' show AppColors;

class ConnectivityProvider extends ChangeNotifier with WidgetsBindingObserver {
  bool _isOnline = true;
  bool _isReady = true;
  final int _reconnectEpoch = 0;
  ConnectivityResult _type = ConnectivityResult.wifi;
  int _offlineHits = 0;
  bool _oauthLock = false;

  bool get isOnline => _isOnline;
  bool get isReady => _isReady;
  int get reconnectEpoch => _reconnectEpoch;
  ConnectivityResult get connectionType => _type;

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _poll;

  ConnectivityProvider() {
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  void lockDuringAuth() {
    _oauthLock = true;
    if (!_isOnline) {
      _isOnline = true;
      notifyListeners();
    }
    Future.delayed(const Duration(seconds: 20), () {
      _oauthLock = false;
    });
  }

  Future<void> _init() async {
    await refresh();
    _sub = _connectivity.onConnectivityChanged.listen(_apply, onError: (_) {});
    _poll = Timer.periodic(const Duration(seconds: 4), (_) => refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Future.delayed(const Duration(milliseconds: 800), refresh);
    }
  }

  Future<void> refresh() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _apply(result);
    } catch (_) {}
  }

  bool _looksOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }

  void _apply(List<ConnectivityResult> results) {
    final rawOnline = _looksOnline(results);
    final type = results.contains(ConnectivityResult.wifi)
        ? ConnectivityResult.wifi
        : results.contains(ConnectivityResult.mobile)
        ? ConnectivityResult.mobile
        : results.contains(ConnectivityResult.ethernet)
        ? ConnectivityResult.ethernet
        : results.contains(ConnectivityResult.vpn)
        ? ConnectivityResult.vpn
        : results.contains(ConnectivityResult.other)
        ? ConnectivityResult.other
        : ConnectivityResult.none;

    if (_oauthLock && !rawOnline) {
      return;
    }

    if (rawOnline) {
      _offlineHits = 0;
      final changed = !_isOnline || type != _type;
      _isOnline = true;
      _type = type;
      _isReady = true;
      if (changed) notifyListeners();
      return;
    }

    _offlineHits++;
    if (_offlineHits < 3) return;

    if (_isOnline) {
      _isOnline = false;
      _type = ConnectivityResult.none;
      _isReady = true;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _poll?.cancel();
    super.dispose();
  }
}

class NoInternetScreen extends StatefulWidget {
  const NoInternetScreen({super.key});

  @override
  State<NoInternetScreen> createState() => _NoInternetScreenState();
}

class _NoInternetScreenState extends State<NoInternetScreen> {
  bool _checking = false;

  Future<void> _retry() async {
    setState(() => _checking = true);
    await context.read<ConnectivityProvider>().refresh();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;

    return Material(
      color: const Color(0xF2020617),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0x26EF4444),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0x66EF4444), width: 2),
              ),
              child: const Icon(
                CupertinoIcons.wifi_slash,
                color: Color(0xFFEF4444),
                size: 34,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              s.noInternet,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                s.noInternetDesc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _checking ? null : _retry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _checking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        s.retry,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
