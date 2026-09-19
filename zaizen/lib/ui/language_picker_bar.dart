import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/l10n/supported_languages.dart';
import 'package:zaizen/locale_provider.dart';

const _border = Color(0xFF232838);
const _primary = Color(0xFF3B82F6);
const _muted = Color(0xFF6B7280);
const _surface = Color(0xFF11151F);

/// Login va boshqa sahifalarda tepada til tanlash.
class LanguagePickerBar extends StatelessWidget {
  const LanguagePickerBar({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>();
    final current = kSupportedLanguages.firstWhere(
      (l) => l.code == locale.locale.languageCode,
      orElse: () => kSupportedLanguages.first,
    );
    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => showLanguageSheet(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xCC11151F),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(current.flag, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  current.code.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(width: 2),
                const Icon(CupertinoIcons.chevron_down, size: 13, color: _muted),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showLanguageSheet(BuildContext context) async {
  final provider = context.read<LocaleProvider>();
  final s = provider.strings;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF0E1420),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) {
      var query = '';
      return StatefulBuilder(
        builder: (ctx, setLocal) {
          final langs = languagesMatching(query);
          return SafeArea(
            child: SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.72,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: _border,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                    child: Row(
                      children: [
                        Text(
                          s.languageScreenTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.pop(ctx),
                          icon: const Icon(CupertinoIcons.xmark, color: _muted, size: 18),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      onChanged: (v) => setLocal(() => query = v),
                      style: const TextStyle(color: Colors.white),
                      cursorColor: _primary,
                      decoration: InputDecoration(
                        hintText: s.languageSearchHint,
                        hintStyle: const TextStyle(color: _muted),
                        prefixIcon: const Icon(CupertinoIcons.search, color: _muted, size: 18),
                        filled: true,
                        fillColor: _surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: _primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: langs.length,
                      itemBuilder: (_, i) {
                        final lang = langs[i];
                        final selected = lang.code == provider.locale.languageCode;
                        return ListTile(
                          leading: Text(lang.flag, style: const TextStyle(fontSize: 22)),
                          title: Text(
                            lang.nativeName,
                            style: TextStyle(
                              color: selected ? _primary : Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(lang.name, style: const TextStyle(color: _muted, fontSize: 12)),
                          trailing: selected
                              ? const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: _primary)
                              : null,
                          onTap: () async {
                            await provider.setLocale(lang.code);
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
