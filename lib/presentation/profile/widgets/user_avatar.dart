import 'dart:io';
import 'package:flutter/material.dart';
import 'package:myecomerceapp/core/constants/app_colors.dart';
import 'package:myecomerceapp/presentation/profile/cubit/profile_state.dart';

class UserAvatar extends StatelessWidget {
  final ProfileLoaded state;
  final double radius;

  const UserAvatar({
    super.key,
    required this.state,
    this.radius = 22,
  });

  @override
  Widget build(BuildContext context) {
    final c = AppColors.of(context);

    if (state.imagePath != null) {
      return CircleAvatar(
        key: ValueKey(state.imagePath),
        radius: radius,
        backgroundImage: FileImage(File(state.imagePath!)),
      );
    }

    final avatarEmojis = ['🦊', '🐨', '🐯', '🦁', '🐻', '🐼', '🦋', '🐙'];
    final avatarColors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFF43C6AC),
      const Color(0xFFFF9800),
      const Color(0xFF00BCD4),
      const Color(0xFF9C27B0),
      const Color(0xFF4CAF50),
      const Color(0xFFE91E63),
    ];

    if (state.avatarIndex >= 0 && state.avatarIndex < avatarEmojis.length) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: avatarColors[state.avatarIndex],
        child: Text(
          avatarEmojis[state.avatarIndex],
          style: TextStyle(fontSize: radius * 0.8),
        ),
      );
    }

    // Default: initials
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.accent, AppColors.accentLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          state.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.7,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
