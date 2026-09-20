import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/core/app_permissions.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/chat/ai_tutor.dart';
import 'package:zaizen/ui/app_theme.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _Msg {
  final String text;
  final bool mine;
  const _Msg(this.text, this.mine);
}

class _AiChatPageState extends State<AiChatPage> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _msgs = <_Msg>[];
  bool _busy = false;
  bool _micOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final code = context.read<LocaleProvider>().locale.languageCode;
      setState(() => _msgs.add(_Msg(AiTutor.welcome(code), false)));
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? ready]) async {
    final text = (ready ?? _ctrl.text).trim();
    if (text.isEmpty || _busy) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(_Msg(text, true));
      _busy = true;
    });
    _jump();
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    final code = context.read<LocaleProvider>().locale.languageCode;
    setState(() {
      _msgs.add(_Msg(AiTutor.reply(text, code), false));
      _busy = false;
    });
    _jump();
  }

  void _jump() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _toggleMic() async {
    if (_micOn) {
      setState(() => _micOn = false);
      return;
    }
    final ok = await AppPermissions.ensure(
      context,
      AppPermissionKind.microphone,
    );
    if (!ok || !mounted) return;
    setState(() => _micOn = true);
  }

  @override
  Widget build(BuildContext context) {
    final c = ZColors.of(context);
    final code = context.watch<LocaleProvider>().locale.languageCode;
    final hints = AiTutor.hints(code);
    final copy = _copy(code);
    return Scaffold(
      backgroundColor: c.bgBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: c.bgBottom,
          gradient: LinearGradient(
            colors: [c.bgTop, c.bgBottom],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.all(8),
                      onPressed: () => Navigator.pop(context),
                      child: Icon(
                        CupertinoIcons.chevron_back,
                        color: c.textPrimary,
                        size: 22,
                      ),
                    ),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: c.primary.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        CupertinoIcons.sparkles,
                        color: c.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            copy.$1,
                            style: TextStyle(
                              color: c.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            copy.$2,
                            style: TextStyle(color: c.textMuted, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _MicDot(on: _micOn),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _msgs.length + (_busy ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_busy && i == _msgs.length) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: c.surface.withValues(alpha: 0.86),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const CupertinoActivityIndicator(radius: 8),
                        ),
                      );
                    }
                    final m = _msgs[i];
                    return Align(
                      alignment: m.mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 11,
                        ),
                        decoration: BoxDecoration(
                          color: m.mine
                              ? c.primary
                              : c.surface.withValues(alpha: 0.86),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(m.mine ? 16 : 4),
                            bottomRight: Radius.circular(m.mine ? 4 : 16),
                          ),
                        ),
                        child: Text(
                          m.text,
                          style: TextStyle(
                            color: m.mine ? Colors.white : c.textPrimary,
                            height: 1.35,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (_msgs.length < 3)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final h in hints)
                        GestureDetector(
                          onTap: () => _send(h),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: c.surface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: c.border.withValues(alpha: 0.6),
                              ),
                            ),
                            child: Text(
                              h,
                              style: TextStyle(
                                color: c.textPrimary,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _toggleMic,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _micOn ? c.primary : c.surface,
                          border: Border.all(
                            color: c.border.withValues(alpha: 0.55),
                          ),
                        ),
                        child: Icon(
                          _micOn
                              ? CupertinoIcons.mic_fill
                              : CupertinoIcons.mic_slash,
                          color: _micOn ? Colors.white : c.textMuted,
                          size: 18,
                        ),
                      ),
                      minimumSize: Size(0, 0),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: c.surface.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: c.border.withValues(alpha: 0.55),
                          ),
                        ),
                        child: TextField(
                          controller: _ctrl,
                          style: TextStyle(color: c.textPrimary, fontSize: 15),
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _send(),
                          decoration: InputDecoration(
                            hintText: copy.$3,
                            hintStyle: TextStyle(
                              color: c.textMuted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: _busy ? null : _send,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: c.primary,
                        ),
                        child: const Icon(
                          CupertinoIcons.arrow_up,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      minimumSize: Size(0, 0),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (String, String, String) _copy(String code) {
    switch (code) {
      case 'ru':
        return ('Zaizen AI', 'Японский репетитор', 'Сообщение...');
      case 'en':
        return ('Zaizen AI', 'Japanese tutor', 'Message...');
      case 'ja':
        return ('Zaizen AI', '日本語チューター', 'メッセージ...');
      default:
        return ('Zaizen AI', 'Yapon tili repetitori', 'Xabar yozing...');
    }
  }
}

class _MicDot extends StatelessWidget {
  final bool on;
  const _MicDot({required this.on});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: on ? const Color(0xFF22C55E) : const Color(0xFF6B7280),
        shape: BoxShape.circle,
      ),
    );
  }
}
