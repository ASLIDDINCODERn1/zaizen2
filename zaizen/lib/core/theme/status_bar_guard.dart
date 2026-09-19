import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StatusBarGuard extends StatefulWidget {
  final Widget child;
  const StatusBarGuard({super.key, required this.child});

  static Future<void> hide() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemStatusBarContrastEnforced: false,
        systemNavigationBarColor: Color(0xFF05070C),
        systemNavigationBarIconBrightness: Brightness.light,
        systemNavigationBarContrastEnforced: false,
      ),
    );
  }

  @override
  State<StatusBarGuard> createState() => _StatusBarGuardState();
}

class _StatusBarGuardState extends State<StatusBarGuard>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    StatusBarGuard.hide();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed ||
        state == AppLifecycleState.inactive) {
      StatusBarGuard.hide();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
