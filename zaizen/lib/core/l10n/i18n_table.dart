import 'package:zaizen/l10n/i18n_core.dart';

const Set<String> kRtlLanguages = {'ar', 'he', 'fa', 'ur'};

const Map<String, Map<String, String>> kI18nUi = {
  'navHome': {'uz': 'Bosh sahifa', 'ru': 'Главная', 'en': 'Home', 'ja': 'ホーム'},
  'navRating': {'uz': 'Reyting', 'ru': 'Рейтинг', 'en': 'Rating', 'ja': 'ランキング'},
  'navProfile': {'uz': 'Profil', 'ru': 'Профиль', 'en': 'Profile', 'ja': 'プロフィール'},
  'navSettings': {'uz': 'Sozlamalar', 'ru': 'Настройки', 'en': 'Settings', 'ja': '設定'},
  'settingsTitle': {'uz': 'Sozlamalar', 'ru': 'Настройки', 'en': 'Settings', 'ja': '設定'},
  'appearance': {'uz': "Ko'rinish", 'ru': 'Внешний вид', 'en': 'Appearance', 'ja': '表示'},
  'darkMode': {'uz': "Qorong'u rejim", 'ru': 'Тёмная тема', 'en': 'Dark mode', 'ja': 'ダークモード'},
  'lightMode': {'uz': "Yorug' rejim", 'ru': 'Светлая тема', 'en': 'Light mode', 'ja': 'ライトモード'},
  'language': {'uz': 'Til', 'ru': 'Язык', 'en': 'Language', 'ja': '言語'},
  'security': {'uz': 'Xavfsizlik', 'ru': 'Безопасность', 'en': 'Security', 'ja': 'セキュリティ'},
  'logout': {'uz': 'Chiqish', 'ru': 'Выйти', 'en': 'Log out', 'ja': 'ログアウト'},
  'signIn': {'uz': 'Kirish', 'ru': 'Войти', 'en': 'Sign in', 'ja': 'ログイン'},
  'save': {'uz': 'Saqlash', 'ru': 'Сохранить', 'en': 'Save', 'ja': '保存'},
  'cancel': {'uz': 'Bekor qilish', 'ru': 'Отмена', 'en': 'Cancel', 'ja': 'キャンセル'},
};

const Map<String, Map<String, String>> kI18n = {
  ...kI18nCore,
};
