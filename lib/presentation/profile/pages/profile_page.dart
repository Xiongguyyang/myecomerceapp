import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/core/localization/app_localizations.dart';
import 'package:myecomerceapp/core/localization/locale_cubit.dart';
import 'package:myecomerceapp/core/localization/locale_keys.dart';
import 'package:myecomerceapp/core/theme/theme_cubit.dart';
import 'package:myecomerceapp/presentation/auth/page/signin.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_cubit.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_state.dart';

// ── Avatar options ─────────────────────────────────────────────────────────────
const _avatarEmojis = ['🦊', '🐨', '🐯', '🦁', '🐻', '🐼', '🦋', '🐙'];
const _avatarColors = [
  Color(0xFF6C63FF),
  Color(0xFFFF6584),
  Color(0xFF43C6AC),
  Color(0xFFFF9800),
  Color(0xFF00BCD4),
  Color(0xFF9C27B0),
  Color(0xFF4CAF50),
  Color(0xFFE91E63),
];

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..loadProfile(),
      child: const _ProfileView(),
    );
  }
}

// ── Main view ─────────────────────────────────────────────────────────────────
class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  bool _isEditing = false;
  late final TextEditingController _firstCtrl = TextEditingController();
  late final TextEditingController _lastCtrl  = TextEditingController();

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    super.dispose();
  }

  void _startEditing(ProfileLoaded state) {
    _firstCtrl.text = state.firstName;
    _lastCtrl.text  = state.lastName;
    setState(() => _isEditing = true);
  }

  void _saveEditing(BuildContext context) {
    context.read<ProfileCubit>().updateProfile(
      firstName: _firstCtrl.text,
      lastName:  _lastCtrl.text,
    );
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Scaffold(
      backgroundColor: c.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back_ios_new, color: c.textPrimary, size: 18),
            ),
          ),
        ),
        title: BlocBuilder<LocaleCubit, Locale>(
          builder: (context, _) => Text(
            context.tr(LK.myProfile),
            style: GoogleFonts.aBeeZee(color: c.textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true,
        actions: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              if (state is! ProfileLoaded) return const SizedBox.shrink();
              return _isEditing
                  ? TextButton(
                      onPressed: () => _saveEditing(context),
                      child: Text(context.tr(LK.save), style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                    )
                  : IconButton(
                      onPressed: () => _startEditing(state),
                      icon: Icon(Icons.edit_outlined, color: c.textSecondary),
                    );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.accent));
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(state.message, style: TextStyle(color: c.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
                    child: Text(context.tr(LK.retry), style: const TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }
          if (state is ProfileLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  _AvatarSection(state: state, isEditing: _isEditing),
                  const SizedBox(height: 16),
                  if (!_isEditing) ...[
                    Text(
                      '${state.firstName} ${state.lastName}'.trim().isEmpty
                          ? 'User'
                          : '${state.firstName} ${state.lastName}'.trim(),
                      style: GoogleFonts.aBeeZee(color: c.textPrimary, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(state.email, style: TextStyle(color: c.textSecondary, fontSize: 14)),
                    const SizedBox(height: 28),
                    _buildInfoCard(context, state, c),
                  ] else ...[
                    const SizedBox(height: 12),
                    _buildEditCard(context, state, c),
                  ],
                  const SizedBox(height: 20),
                  _buildMenuSection(context, c),
                  const SizedBox(height: 20),
                  _buildSignOutButton(context, c),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── Info card (read-only view) ───────────────────────────────────────────────
  Widget _buildInfoCard(BuildContext context, ProfileLoaded state, AppColors c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LK.personalInfo),
            style: TextStyle(color: c.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2),
          ),
          const SizedBox(height: 16),
          _infoRow(context, Icons.person_outline, context.tr(LK.firstName), state.firstName, c),
          Divider(color: c.divider, height: 24),
          _infoRow(context, Icons.person, context.tr(LK.lastName), state.lastName, c),
          Divider(color: c.divider, height: 24),
          _infoRow(context, Icons.email_outlined, context.tr(LK.email), state.email, c, isLocked: true),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value, AppColors c, {bool isLocked = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.accent.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.accent, size: 18),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: c.textHint, fontSize: 11)),
              const SizedBox(height: 2),
              Text(value.isEmpty ? '—' : value, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
        if (isLocked)
          Icon(Icons.lock_outline, color: c.textHint, size: 18),
      ],
    );
  }

  // ── Edit card (both names at once) ─────────────────────────────────────────
  Widget _buildEditCard(BuildContext context, ProfileLoaded state, AppColors c) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.tr(LK.editProfile),
            style: const TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          _editField(c, _firstCtrl, context.tr(LK.firstName), Icons.person_outline),
          const SizedBox(height: 14),
          _editField(c, _lastCtrl, context.tr(LK.lastName), Icons.person),
          const SizedBox(height: 14),
          // Email read-only
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: c.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.email_outlined, color: c.textHint, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr(LK.email), style: TextStyle(color: c.textHint, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text(state.email, style: TextStyle(color: c.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
                Icon(Icons.lock_outline, color: c.textHint, size: 16),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _saveEditing(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(context.tr(LK.saveEdit), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _editField(AppColors c, TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      style: TextStyle(color: c.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: c.textHint),
        prefixIcon: Icon(icon, color: AppColors.accent, size: 20),
        filled: true,
        fillColor: c.surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: AppColors.accent),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      ),
    );
  }

  // ── Menu section ────────────────────────────────────────────────────────────
  Widget _buildMenuSection(BuildContext context, AppColors c) {
    return BlocBuilder<LocaleCubit, Locale>(
      builder: (context, _) {
        final items = <(IconData, String, String, VoidCallback?)>[
          (Icons.language,      context.tr(LK.changeLanguage), context.tr(LK.languageSubtitle),  () => _showLanguagePicker(context)),
          (Icons.palette_outlined, context.tr(LK.appTheme),   context.tr(LK.appThemeSub),         () => _showThemePicker(context)),
          (Icons.notifications_outlined, context.tr(LK.notifications),  context.tr(LK.notificationsSub),  null),
          (Icons.lock_outline,  context.tr(LK.privacySecurity), context.tr(LK.privacySecuritySub), null),
          (Icons.help_outline,  context.tr(LK.helpSupport),    context.tr(LK.helpSupportSub),      null),
        ];

        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: c.divider),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item  = entry.value;
              return Column(
                children: [
                  ListTile(
                    onTap: item.$4 ?? () {},
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.$1, color: c.textSecondary, size: 18),
                    ),
                    title: Text(item.$2, style: TextStyle(color: c.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
                    subtitle: Text(item.$3, style: TextStyle(color: c.textHint, fontSize: 12)),
                    trailing: Icon(Icons.chevron_right, color: c.textHint, size: 20),
                  ),
                  if (index < items.length - 1)
                    Divider(color: c.divider, height: 1, indent: 60),
                ],
              );
            }).toList(),
          ),
        );
      },
    );
  }

  // ── Language picker ─────────────────────────────────────────────────────────
  void _showLanguagePicker(BuildContext context) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        final currentCode = context.read<LocaleCubit>().state.languageCode;
        return BlocProvider.value(
          value: context.read<LocaleCubit>(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: c.divider, borderRadius: BorderRadius.circular(2)))),
                Text(context.tr(LK.selectLanguage), style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ...AppLanguage.values.map((lang) {
                  final isSelected = currentCode == lang.code;
                  return _LanguageTile(
                    language: lang,
                    isSelected: isSelected,
                    onTap: () {
                      context.read<LocaleCubit>().setLanguage(lang.code);
                      Navigator.pop(ctx);
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Theme picker ────────────────────────────────────────────────────────────
  void _showThemePicker(BuildContext context) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<ThemeCubit>(),
          child: BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, currentMode) {
              final sheetColors = AppColors.of(context);
              final options = [
                (ThemeMode.dark,   '🌙', context.tr(LK.themeDark)),
                (ThemeMode.light,  '☀️', context.tr(LK.themeLight)),
                (ThemeMode.system, '📱', context.tr(LK.themeSystem)),
              ];
              return Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: sheetColors.divider, borderRadius: BorderRadius.circular(2)))),
                    Text(context.tr(LK.selectTheme), style: TextStyle(color: sheetColors.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ...options.map((opt) {
                      final isSelected = currentMode == opt.$1;
                      return GestureDetector(
                        onTap: () {
                          context.read<ThemeCubit>().setTheme(opt.$1);
                          Navigator.pop(ctx);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : sheetColors.surfaceLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isSelected ? AppColors.accent : sheetColors.divider, width: isSelected ? 1.5 : 1),
                          ),
                          child: Row(
                            children: [
                              Text(opt.$2, style: const TextStyle(fontSize: 22)),
                              const SizedBox(width: 14),
                              Text(opt.$3, style: TextStyle(color: isSelected ? AppColors.accent : sheetColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                              const Spacer(),
                              if (isSelected) const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Sign-out button ─────────────────────────────────────────────────────────
  Widget _buildSignOutButton(BuildContext context, AppColors c) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: c.surface,
              title: Text(context.tr(LK.signOutConfirm), style: TextStyle(color: c.textPrimary)),
              content: Text(context.tr(LK.signOutQuestion), style: TextStyle(color: c.textSecondary)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: Text(context.tr(LK.cancel), style: TextStyle(color: c.textSecondary)),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: Text(context.tr(LK.signOut), style: const TextStyle(color: AppColors.error)),
                ),
              ],
            ),
          );
          if (confirmed == true && context.mounted) {
            await context.read<ProfileCubit>().signOut();
            if (context.mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const SigninPage()),
                (route) => false,
              );
            }
          }
        },
        icon: const Icon(Icons.logout, color: AppColors.error, size: 18),
        label: Text(context.tr(LK.signOut), style: const TextStyle(color: AppColors.error, fontSize: 15)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

// ── Avatar section with image picker and avatar grid ──────────────────────────
class _AvatarSection extends StatelessWidget {
  final ProfileLoaded state;
  final bool isEditing;

  const _AvatarSection({required this.state, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        _buildAvatar(c),
        if (isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showPhotoOptions(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.background, width: 2),
                ),
                child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(AppColors c) {
    if (state.imagePath != null) {
      return CircleAvatar(
        radius: 52,
        backgroundImage: FileImage(File(state.imagePath!)),
      );
    }
    if (state.avatarIndex >= 0 && state.avatarIndex < _avatarEmojis.length) {
      return CircleAvatar(
        radius: 52,
        backgroundColor: _avatarColors[state.avatarIndex],
        child: Text(_avatarEmojis[state.avatarIndex], style: const TextStyle(fontSize: 40)),
      );
    }
    // Default: initials
    return Container(
      width: 104,
      height: 104,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: Color(0x6612AEC6), blurRadius: 16, offset: Offset(0, 6))],
      ),
      child: Center(
        child: Text(state.initials, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
    final c = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => BlocProvider.value(
        value: context.read<ProfileCubit>(),
        child: _PhotoOptionsSheet(context: context),
      ),
    );
  }
}

class _PhotoOptionsSheet extends StatelessWidget {
  final BuildContext context;
  const _PhotoOptionsSheet({required this.context});

  Future<void> _pick(ImageSource source, BuildContext ctx) async {
    Navigator.pop(ctx);
    final picker = ImagePicker();
    final file   = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 600);
    if (file != null && ctx.mounted) {
      ctx.read<ProfileCubit>().setImagePath(file.path);
    }
  }

  @override
  Widget build(BuildContext sheetCtx) {
    final c = AppColors.of(sheetCtx);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, margin: const EdgeInsets.only(bottom: 20), decoration: BoxDecoration(color: c.divider, borderRadius: BorderRadius.circular(2)))),
          Text(context.tr(LK.uploadPhoto), style: TextStyle(color: c.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _optionTile(sheetCtx, c, Icons.camera_alt_outlined, context.tr(LK.camera),  () => _pick(ImageSource.camera,  sheetCtx)),
          const SizedBox(height: 10),
          _optionTile(sheetCtx, c, Icons.photo_library_outlined, context.tr(LK.gallery), () => _pick(ImageSource.gallery, sheetCtx)),
          Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Divider(color: c.divider)),
          Text(context.tr(LK.chooseAvatar), style: TextStyle(color: c.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12,
            ),
            itemCount: _avatarEmojis.length,
            itemBuilder: (_, i) => GestureDetector(
              onTap: () {
                Navigator.pop(sheetCtx);
                sheetCtx.read<ProfileCubit>().setAvatar(i);
              },
              child: Container(
                decoration: BoxDecoration(color: _avatarColors[i], shape: BoxShape.circle),
                child: Center(child: Text(_avatarEmojis[i], style: const TextStyle(fontSize: 30))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _optionTile(BuildContext ctx, AppColors c, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.divider),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.accent, size: 22),
            const SizedBox(width: 14),
            Text(label, style: TextStyle(color: c.textPrimary, fontSize: 15, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Language tile ─────────────────────────────────────────────────────────────
class _LanguageTile extends StatelessWidget {
  final AppLanguage language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({required this.language, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accent.withValues(alpha: 0.15) : c.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.accent : c.divider, width: isSelected ? 1.5 : 1),
        ),
        child: Row(
          children: [
            Text(language.flag, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(language.nativeLabel, style: TextStyle(color: isSelected ? AppColors.accent : c.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                  Text(language.label, style: TextStyle(color: c.textHint, fontSize: 12)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.accent, size: 22),
          ],
        ),
      ),
    );
  }
}
