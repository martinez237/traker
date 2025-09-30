import 'package:flutter/widgets.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static const supportedLocales = [Locale('en'), Locale('fr')];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appTitle => locale.languageCode == 'fr' ? 'Journal d’humeur' : 'Mood Journal';
  String get save => locale.languageCode == 'fr' ? 'Enregistrer' : 'Save';
  String get note => locale.languageCode == 'fr' ? 'Note (optionnel)' : 'Note (optional)';
  String get intensity => locale.languageCode == 'fr' ? 'Intensité' : 'Intensity';
  String get tags => locale.languageCode == 'fr' ? 'Tags' : 'Tags';
  String get emotion => locale.languageCode == 'fr' ? 'Émotion' : 'Emotion';
  String get today => locale.languageCode == 'fr' ? 'Aujourd’hui' : 'Today';
  String get export => locale.languageCode == 'fr' ? 'Exporter' : 'Export';
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'fr'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}