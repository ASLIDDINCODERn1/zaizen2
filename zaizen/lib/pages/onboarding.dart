import 'dart:async';

import 'package:flutter/material.dart';
import 'package:zaizen/core/app_permissions.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;

  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  static const _title = 'ZAIZEN • ザイゼン';

  late final AnimationController _logoCtrl;
  late final AnimationController _cursorCtrl;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;

  String _typed = '';
  Timer? _typeTimer;
  int _charIndex = 0;
  bool _startTyping = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _cursorCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..repeat(reverse: true);

    _logoFade = CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(
      begin: 0.72,
      end: 1,
    ).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOutBack));

    _logoCtrl.forward().whenComplete(_beginTypewriter);
  }

  void _beginTypewriter() {
    if (!mounted) return;
    setState(() => _startTyping = true);
    _typeTimer = Timer.periodic(const Duration(milliseconds: 78), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_charIndex >= _title.length) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 700), _goNext);
        return;
      }
      setState(() {
        _charIndex += 1;
        _typed = _title.substring(0, _charIndex);
      });
    });
  }

  Future<void> _goNext() async {
    if (!mounted || _leaving) return;
    _leaving = true;
    AppPermissions.requestStartup;
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 360),
        pageBuilder: (_, _, _) => widget.nextScreen,
        transitionsBuilder: (_, animation, _, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _typeTimer?.cancel();
    _logoCtrl.dispose();
    _cursorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3D91),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FadeTransition(
              opacity: _logoFade,
              child: ScaleTransition(
                scale: _logoScale,
                child: Image.asset(
                  'assets/logo.png',
                  width: 132,
                  filterQuality: FilterQuality.medium,
                  gaplessPlayback: true,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 72,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 32,
              child: _startTyping
                  ? FadeTransition(
                      opacity: const AlwaysStoppedAnimation(1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _typed,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 3,
                              color: Colors.white,
                            ),
                          ),
                          FadeTransition(
                            opacity: _cursorCtrl,
                            child: Container(
                              margin: const EdgeInsets.only(left: 2, bottom: 2),
                              width: 2,
                              height: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
