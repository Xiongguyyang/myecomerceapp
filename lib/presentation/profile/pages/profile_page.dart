import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/presentation/auth/page/signin.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_cubit.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_state.dart';

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

class _ProfileView extends StatefulWidget {
  const _ProfileView();

  @override
  State<_ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<_ProfileView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  String? _editingField;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.pop(context),
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
        title: Text(
          'My Profile',
          style: GoogleFonts.aBeeZee(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<ProfileCubit>().loadProfile(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(color: Colors.white),
                    ),
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
                  const SizedBox(height: 16),
                  _buildAvatar(state),
                  const SizedBox(height: 16),
                  Text(
                    state.firstName,
                    style: GoogleFonts.aBeeZee(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoCard(state),
                  const SizedBox(height: 20),
                  _buildMenuSection(context),
                  const SizedBox(height: 20),
                  _buildSignOutButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildAvatar(ProfileLoaded state) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          state.initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ProfileLoaded state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.person_outline,
            'First Name',
            state.firstName,
            state,
            'firstName',
            _firstNameController,
          ),
          const Divider(color: AppColors.divider, height: 24),
          _buildInfoRow(
            Icons.person,
            'Last Name',
            state.lastName,
            state,
            'lastName',
            _lastNameController,
          ),
          const Divider(color: AppColors.divider, height: 24),
          _buildInfoRow(
            Icons.email_outlined,
            'Email',
            state.email,
            state,
            'email',
            _emailController,
          ),
          const SizedBox(height: 16),
          if (_editingField != null)
            Container(
              alignment: Alignment.center,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 251, 251, 251),
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
                ),
                onPressed: () {
                  context.read<ProfileCubit>().updateProfile(
                    firstName: _firstNameController.text,
                    lastName: _lastNameController.text,
                    email: _emailController.text,
                  );
                  setState(() => _editingField = null); // close any open field
                },
                child: const Text(
                  "Save edit",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value,
    ProfileLoaded state,
    String fieldKey,
    TextEditingController controller,
  ) {
    final isEditing = _editingField == fieldKey;

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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    if (isEditing)
                      TextFormField(
                        controller: controller,
                        autofocus: true,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 6),
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      Text(
                        value.isEmpty ? '—' : value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
              Spacer(),
              Container(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    setState(() {
                      if (isEditing) {
                        _editingField = null; // close edit mode
                      } else {
                        _editingField = fieldKey;
                        controller.text = value; // pre-fill with current value
                      }
                    });
                  },
                  icon: Icon(
                    isEditing ? Icons.check : Icons.edit_outlined,
                    color: isEditing ? AppColors.accent : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuSection(BuildContext context) {
    final items = [
      (Icons.shopping_bag_outlined, 'My Orders', 'View your order history'),
      (
        Icons.location_on_outlined,
        'Saved Addresses',
        'Manage delivery addresses',
      ),
      (Icons.notifications_outlined, 'Notifications', 'Manage your alerts'),
      (Icons.lock_outline, 'Privacy & Security', 'Password and security'),
      (Icons.help_outline, 'Help & Support', 'FAQs and contact us'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Column(
            children: [
              ListTile(
                onTap: () {},
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    item.$1,
                    color: AppColors.textSecondary,
                    size: 18,
                  ),
                ),
                title: Text(
                  item.$2,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: Text(
                  item.$3,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ),
              if (index < items.length - 1)
                const Divider(color: AppColors.divider, height: 1, indent: 60),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () async {
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (_) => AlertDialog(
              backgroundColor: AppColors.surface,
              title: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              content: const Text(
                'Are you sure you want to sign out?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.error),
                  ),
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
        label: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.error, fontSize: 15),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.error),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
