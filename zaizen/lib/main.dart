import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zaizen/auth/auth_gate.dart';
import 'package:zaizen/auth/auth_links.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/auth/profile_store.dart';
import 'package:zaizen/l10n/i18n_table.dart';
import 'package:zaizen/l10n/supported_languages.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/no_internet_screen.dart';
import 'package:zaizen/pages/onboarding.dart';
import 'package:zaizen/ui/app_theme.dart';
import 'package:zaizen/ui/status_bar_guard.dart';

const _supabaseUrl = 'https://vazzsnxyqbumqstjgsln.supabase.co';
const _supabaseAnonKey = 'sb_publishable_0gYD9sXBEp5N16haSniQew_6bsbiV3X';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
      detectSessionInUri: true,
    ),
  );
  AuthService.instance.startSessionListener();
  await AuthLinks.instance.start();
  await StatusBarGuard.hide();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => ProfileStore()),
      ],
      child: const StatusBarGuard(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final theme = context.watch<ThemeProvider>();
    final net = context.watch<ConnectivityProvider>();
    final rtl = kRtlLanguages.contains(localeProvider.locale.languageCode);
    return MaterialApp(
      title: 'Zaizen App',
      locale: localeProvider.locale,
      supportedLocales: [
        for (final lang in kSupportedLanguages) Locale(lang.code),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supported) {
        if (locale == null) return const Locale('uz');
        for (final s in supported) {
          if (s.languageCode == locale.languageCode) return s;
        }
        return const Locale('uz');
      },
      themeMode: theme.mode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF3F6FB),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3B82F6),
          brightness: Brightness.dark,
          surface: const Color(0xFF11151F),
        ),
        scaffoldBackgroundColor: const Color(0xFF0A0E17),
      ),
      builder: (context, child) {
        StatusBarGuard.hide();
        final wrapped = Directionality(
          textDirection: rtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
        return Stack(
          fit: StackFit.expand,
          children: [
            wrapped,
            if (net.isReady && !net.isOnline) const NoInternetScreen(),
          ],
        );
      },
      home: const SplashScreen(nextScreen: AuthGate()),
      debugShowCheckedModeBanner: false,
    );
  }
}
