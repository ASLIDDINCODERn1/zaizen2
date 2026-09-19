import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/core/l10n/locale_provider.dart';
import 'package:zaizen/l10n/app_strings.dart';

/// UI widgetlar: L.of(context).signIn
/// Servislar: LanguageScope.strings
class L {
  static AppStrings of(BuildContext context) {
    return context.watch<LocaleProvider>().strings;
  }

  static AppStrings read(BuildContext context) {
    return context.read<LocaleProvider>().strings;
  }

  static AppStrings get current => LanguageScope.strings;
}
