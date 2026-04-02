import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kLangKey = 'flexy_language_code';

/// Manages the active [Locale] and persists the choice across launches.
class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('en'));

  /// Call once at startup to restore the saved language.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_kLangKey) ?? 'en';
    emit(Locale(code));
  }

  /// Switch language and persist the choice.
  Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLangKey, languageCode);
    emit(Locale(languageCode));
  }
}
