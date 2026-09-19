import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/l10n/supported_languages.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/login.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedCode;
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    final code = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    _selectedCode = isLanguageUnlocked(code) ? code : 'uz';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _selectLanguage(AppLanguage lang) async {
    if (!lang.isUnlocked) return;
    if (lang.code == _selectedCode) return;
    setState(() => _selectedCode = lang.code);
    await Provider.of<LocaleProvider>(context, listen: false).setLocale(lang.code);
    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final langs = languagesMatching(_query);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.chevron_back, color: AppColors.textPrimary),
        ),
        title: Text(
          s.languageScreenTitle,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14.5),
                  decoration: InputDecoration(
                    hintText: s.languageSearchHint,
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    prefixIcon: const Icon(CupertinoIcons.search, color: AppColors.textMuted, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    for (int i = 0; i < langs.length; i++) ...[
                      _FlagLangTile(
                        flag: langs[i].flag,
                        name: langs[i].name,
                        nativeName: '${langs[i].nativeName}  •  ${langs[i].country}',
                        isSelected: _selectedCode == langs[i].code && langs[i].isUnlocked,
                        locked: !langs[i].isUnlocked,
                        onTap: langs[i].isUnlocked ? () => _selectLanguage(langs[i]) : null,
                      ),
                      if (i < langs.length - 1)
                        const Divider(height: 1, color: AppColors.border, indent: 70),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlagLangTile extends StatelessWidget {
  final String flag;
  final String name;
  final String nativeName;
  final bool isSelected;
  final bool locked;
  final VoidCallback? onTap;

  const _FlagLangTile({
    required this.flag,
    required this.name,
    required this.nativeName,
    required this.isSelected,
    required this.locked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onTap,
      child: Opacity(
        opacity: locked ? 0.55 : 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.border.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(child: Text(flag, style: const TextStyle(fontSize: 26))),
                  ),
                  if (locked)
                    Positioned(
                      right: -4,
                      bottom: -4,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1F2937),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(CupertinoIcons.lock_fill, size: 11, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(nativeName, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                  ],
                ),
              ),
              if (locked)
                const Icon(CupertinoIcons.lock_fill, color: AppColors.textMuted, size: 18)
              else if (isSelected)
                const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: AppColors.primary, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
