import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/login.dart';

/// ─── 1. SHAXSIY MA'LUMOTLAR EKRANI ─────────────────────────────────────────
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController(text: 'Aziz Karimov');
  final _emailController = TextEditingController(
    text: 'aziz.karimov@gmail.com',
  );
  final _phoneController = TextEditingController(text: '+998 90 123 45 67');

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    return _SubBaseScaffold(
      title: s.personalInfo,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Stack(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.surface,
                    child: Icon(
                      CupertinoIcons.person_fill,
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.camera_fill,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _CustomField(label: s.fullName, controller: _nameController),
          const SizedBox(height: 16),
          _CustomField(label: s.email, controller: _emailController),
          const SizedBox(height: 16),
          _CustomField(label: s.phone, controller: _phoneController),
          const SizedBox(height: 32),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(s.savedSuccess)));
              Navigator.pop(context);
            },
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  s.save,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── 2. BILDIRISHNOMALAR EKRANI ─────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _lessonReminders = true;
  bool _newsUpdates = false;

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    return _SubBaseScaffold(
      title: s.notifications,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                _SwitchItem(
                  title: s.pushNotifications,
                  subtitle: s.pushNotificationsDesc,
                  value: _pushNotifications,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 1, color: AppColors.border, indent: 20),
                _SwitchItem(
                  title: s.lessonReminders,
                  subtitle: s.lessonRemindersDesc,
                  value: _lessonReminders,
                  onChanged: (val) => setState(() => _lessonReminders = val),
                ),
                const Divider(height: 1, color: AppColors.border, indent: 20),
                _SwitchItem(
                  title: s.newsUpdates,
                  subtitle: s.newsUpdatesDesc,
                  value: _newsUpdates,
                  onChanged: (val) => setState(() => _newsUpdates = val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── 3. TILNI TANLASH EKRANI ───────────────────────────────────────────────
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedCode;

  static const List<Map<String, String>> _langs = [
    {
      'code': 'uz',
      'name': "O'zbekcha",
      'nativeName': "O'zbek tili",
      'flag': '🇺🇿',
    },
    {
      'code': 'ru',
      'name': 'Русский',
      'nativeName': 'Русский язык',
      'flag': '🇷🇺',
    },
    {
      'code': 'en',
      'name': 'English',
      'nativeName': 'English language',
      'flag': '🇬🇧',
    },
    {'code': 'ja', 'name': '日本語', 'nativeName': '日本語', 'flag': '🇯🇵'},
  ];

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    _selectedCode = provider.locale.languageCode;
  }

  Future<void> _selectLanguage(String code) async {
    if (code == _selectedCode) return;
    setState(() => _selectedCode = code);
    final provider = Provider.of<LocaleProvider>(context, listen: false);
    await provider.setLocale(code);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(provider.strings.languageSaved),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    return _SubBaseScaffold(
      title: s.languageScreenTitle,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header info card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.globe,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    s.languageScreenTitle,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Language list
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _langs.length; i++) ...[
                  _LangTile(
                    flag: _langs[i]['flag']!,
                    name: _langs[i]['name']!,
                    nativeName: _langs[i]['nativeName']!,
                    isSelected: _selectedCode == _langs[i]['code'],
                    onTap: () => _selectLanguage(_langs[i]['code']!),
                  ),
                  if (i < _langs.length - 1)
                    const Divider(
                      height: 1,
                      color: AppColors.border,
                      indent: 70,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Individual language row tile with press animation
class _LangTile extends StatefulWidget {
  final String flag;
  final String name;
  final String nativeName;
  final bool isSelected;
  final VoidCallback onTap;

  const _LangTile({
    required this.flag,
    required this.name,
    required this.nativeName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_LangTile> createState() => _LangTileState();
}

class _LangTileState extends State<_LangTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(
            children: [
              // Flag in a rounded container
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: widget.isSelected
                      ? AppColors.primary.withValues(alpha: 0.15)
                      : AppColors.border.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: widget.isSelected
                      ? Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          width: 1.5,
                        )
                      : null,
                ),
                child: Center(
                  child: Text(
                    widget.flag,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Language names
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: TextStyle(
                        color: widget.isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.nativeName,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Animated checkmark
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    ScaleTransition(scale: anim, child: child),
                child: widget.isSelected
                    ? const Icon(
                        CupertinoIcons.checkmark_alt_circle_fill,
                        color: AppColors.primary,
                        size: 24,
                        key: ValueKey('check'),
                      )
                    : const SizedBox(width: 24, key: ValueKey('empty')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ─── 4. YORDAM MARKAZI EKRANI ──────────────────────────────────────────────
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    return _SubBaseScaffold(
      title: s.helpCenter,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.contactUs,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _HelpContactRow(
                  icon: CupertinoIcons.chat_bubble_2_fill,
                  title: s.telegramSupport,
                  subtitle: '@yordam_admin',
                ),
                const Divider(height: 16, color: AppColors.border),
                _HelpContactRow(
                  icon: CupertinoIcons.mail_solid,
                  title: s.email,
                  subtitle: 'support@example.com',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            s.faq,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.all(16),
            child: Text(
              s.faqAnswer,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ─── SUB EKRANLAR UCHUN UMUMIY VIDJETLAR ──────────────────────────────────
class _SubBaseScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  const _SubBaseScaffold({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgBottom,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(
            CupertinoIcons.chevron_back,
            color: AppColors.textPrimary,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.bgBottom,
          gradient: LinearGradient(
            colors: [AppColors.bgTop, AppColors.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(child: body),
      ),
    );
  }
}

class _CustomField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  const _CustomField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.5,
            ),
            decoration: const InputDecoration(border: InputBorder.none),
          ),
        ),
      ],
    );
  }
}

class _SwitchItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchItem({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            value: value,
            activeTrackColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _HelpContactRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _HelpContactRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
