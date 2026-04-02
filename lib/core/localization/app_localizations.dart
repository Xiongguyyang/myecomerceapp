import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myecomerceapp/core/localization/locale_cubit.dart';
import 'package:myecomerceapp/core/localization/translations/en.dart';
import 'package:myecomerceapp/core/localization/translations/lo.dart';

/// Supported languages with display metadata.
enum AppLanguage {
  en(code: 'en', label: 'English', nativeLabel: 'English', flag: '🇬🇧'),
  lo(code: 'lo', label: 'Lao', nativeLabel: 'ພາສາລາວ', flag: '🇱🇦');

  final String code;
  final String label;
  final String nativeLabel;
  final String flag;
  const AppLanguage({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.flag,
  });

  static AppLanguage fromCode(String code) =>
      AppLanguage.values.firstWhere((l) => l.code == code, orElse: () => AppLanguage.en);
}

/// Translation lookup.
/// Usage:  AppLocalizations.of(context).tr(LK.signIn)
///    or:  context.tr(LK.signIn)   (via extension below)
class AppLocalizations {
  final String _langCode;

  AppLocalizations(this._langCode);

  static const _maps = <String, Map<String, String>>{
    'en': enTranslations,
    'lo': loTranslations,
  };

  static AppLocalizations of(BuildContext context) {
    final code = context.read<LocaleCubit>().state.languageCode;
    return AppLocalizations(code);
  }

  String tr(String key) =>
      _maps[_langCode]?[key] ?? _maps['en']?[key] ?? key;
}

/// Convenience extension — context.tr(LK.signIn)
extension LocalizationExtension on BuildContext {
  String tr(String key) => AppLocalizations.of(this).tr(key);
}
