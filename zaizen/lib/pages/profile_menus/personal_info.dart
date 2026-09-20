import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:zaizen/auth/auth_service.dart';
import 'package:zaizen/auth/profile_store.dart';
import 'package:zaizen/locale_provider.dart';
import 'package:zaizen/pages/login.dart' show AppColors;

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  late final TextEditingController _nameController;
  bool _saving = false;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<ProfileStore>();
    final auth = AuthService.instance;
    _nameController = TextEditingController(
      text: p.name.isNotEmpty ? p.name : auth.displayName,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
      maxWidth: 1024,
      maxHeight: 1024,
      requestFullMetadata: false,
    );
    if (picked == null) return;
    setState(() => _uploading = true);
    try {
      final bytes = await picked.readAsBytes();
      final ext = picked.name.contains('.')
          ? picked.name.split('.').last
          : 'jpg';
      await AuthService.instance.uploadAvatar(bytes, ext);
      if (mounted) await context.read<ProfileStore>().refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  Future<void> _save() async {
    final s = context.read<LocaleProvider>().strings;
    final name = _nameController.text.trim();
    if (name.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.authNameShort),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await AuthService.instance.updateProfile(fullName: name);
      if (mounted) await context.read<ProfileStore>().refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(s.savedSuccess)));
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleProvider>().strings;
    final profile = context.watch<ProfileStore>();
    final auth = AuthService.instance;
    final avatar = profile.avatarUrl ?? auth.avatarUrl;
    final email = profile.email.isNotEmpty ? profile.email : auth.email;

    return Scaffold(
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
          s.personalInfo,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.bgBottom,
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
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _uploading ? null : _pickPhoto,
                  child: Stack(
                    children: [
                      Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 2,
                          ),
                        ),
                        child: ClipOval(
                          child: _uploading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: AppColors.primary,
                                    strokeWidth: 2,
                                  ),
                                )
                              : avatar != null && avatar.isNotEmpty
                              ? Image.network(
                                  avatar,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, _, _) => const Icon(
                                    CupertinoIcons.person_fill,
                                    size: 44,
                                    color: AppColors.primary,
                                  ),
                                )
                              : const Icon(
                                  CupertinoIcons.person_fill,
                                  size: 44,
                                  color: AppColors.primary,
                                ),
                        ),
                      ),
                      const Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppColors.primary,
                          child: Icon(
                            CupertinoIcons.camera_fill,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                s.fullName,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              _box(
                TextField(
                  controller: _nameController,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14.5,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                s.email,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              _box(
                TextField(
                  readOnly: true,
                  controller: TextEditingController(text: email),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14.5,
                  ),
                  decoration: const InputDecoration(border: InputBorder.none),
                ),
              ),
              const SizedBox(height: 32),
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: _saving ? null : _save,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _saving
                        ? const CupertinoActivityIndicator(color: Colors.white)
                        : Text(
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
        ),
      ),
    );
  }

  Widget _box(Widget child) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: child,
    );
  }
}
