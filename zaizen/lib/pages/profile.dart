import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/auth/profile_store.dart';
import 'package:zaizen/core/app_permissions.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/profile_menus/personal_info.dart';
import 'package:zaizen/ui/app_theme.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _busy = false;

  Future<void> _editName(BuildContext context) async {
    final store = context.read<ProfileStore>();
    final s = context.read<LocaleProvider>().strings;
    final ctrl = TextEditingController(
      text: store.name.isNotEmpty
          ? store.name
          : AuthService.instance.displayName,
    );
    final ok = await showCupertinoDialog<bool>(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(s.editName),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(controller: ctrl),
        ),
        actions: [
          CupertinoDialogAction(
            child: Text(s.cancel),
            onPressed: () => Navigator.pop(ctx, false),
          ),
          CupertinoDialogAction(
            child: Text(s.save),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );
    if (ok == true && ctrl.text.trim().isNotEmpty) {
      await AuthService.instance.updateProfile(fullName: ctrl.text.trim());
      if (mounted) await context.read<ProfileStore>().refresh();
    }
  }

  Future<void> _editPhoto() async {
    final allowed = await AppPermissions.ensure(
      context,
      AppPermissionKind.photos,
    );
    if (!allowed || !mounted) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
      requestFullMetadata: false,
    );
    if (picked == null) return;
    setState(() => _busy = true);
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.contains('.')
          ? picked.name.split('.').last
          : 'jpg';
      await AuthService.instance.uploadAvatar(bytes, ext);
      if (mounted) await context.read<ProfileStore>().refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final profile = context.watch<ProfileStore>();
    final auth = AuthService.instance;
    final avatar = profile.avatarUrl ?? auth.avatarUrl;
    final c = ZColors.of(context);
    return ListView(
      padding: PageGutters.of(context),
      physics: const BouncingScrollPhysics(),
      children: [
        Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _busy ? null : _editPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 92,
                      height: 92,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: c.primary, width: 2),
                      ),
                      child: ClipOval(
                        child: avatar != null
                            ? Image.network(
                                avatar,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) => Icon(
                                  CupertinoIcons.person_fill,
                                  color: c.primary,
                                  size: 40,
                                ),
                              )
                            : Icon(
                                CupertinoIcons.person_fill,
                                color: c.primary,
                                size: 40,
                              ),
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor: c.primary,
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () => _editName(context),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        profile.name.isEmpty ? 'User' : profile.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: c.textPrimary,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(CupertinoIcons.pencil, size: 16, color: c.textMuted),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                profile.email.isEmpty ? auth.email : profile.email,
                style: TextStyle(color: c.textMuted, fontSize: 13.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 26),
        Container(
          decoration: BoxDecoration(
            color: c.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: c.border.withValues(alpha: 0.55),
              width: 0.7,
            ),
          ),
          child: CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () {
              Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => const PersonalInfoScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      CupertinoIcons.person_crop_circle_fill,
                      color: c.primary,
                      size: 17,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      s.personalInfo,
                      style: TextStyle(
                        color: c.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 14.5,
                      ),
                    ),
                  ),
                  Icon(
                    CupertinoIcons.chevron_right,
                    color: c.textMuted,
                    size: 16,
                  ),
                ],
              ),
            ),
            minimumSize: Size(0, 0),
          ),
        ),
      ],
    );
  }
}
