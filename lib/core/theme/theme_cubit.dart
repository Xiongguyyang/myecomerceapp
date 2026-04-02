import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'flexy_theme_mode';

  ThemeCubit() : super(ThemeMode.dark);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    final mode = switch (stored) {
      'light'  => ThemeMode.light,
      'system' => ThemeMode.system,
      _        => ThemeMode.dark,
    };
    emit(mode);
  }

  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }
}
