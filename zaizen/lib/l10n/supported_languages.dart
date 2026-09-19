class AppLanguage {
  final String code;
  final String name;
  final String nativeName;
  final String flag;
  final String country;

  const AppLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flag,
    required this.country,
  });

  bool get isUnlocked => kUnlockedLanguageCodes.contains(code);
}

const Set<String> kUnlockedLanguageCodes = {'uz', 'ru', 'en', 'ja'};

bool isLanguageUnlocked(String code) => kUnlockedLanguageCodes.contains(code);

const List<AppLanguage> kSupportedLanguages = [
  AppLanguage(code: 'uz', name: "O'zbekcha", nativeName: "O'zbek tili", flag: '🇺🇿', country: "O'zbekiston"),
  AppLanguage(code: 'ru', name: 'Русский', nativeName: 'Русский язык', flag: '🇷🇺', country: 'Россия'),
  AppLanguage(code: 'en', name: 'English', nativeName: 'English', flag: '🇬🇧', country: 'United Kingdom'),
  AppLanguage(code: 'ja', name: '日本語', nativeName: '日本語', flag: '🇯🇵', country: '日本'),
  AppLanguage(code: 'ko', name: '한국어', nativeName: '한국어', flag: '🇰🇷', country: '대한민국'),
  AppLanguage(code: 'zh', name: '中文', nativeName: '简体中文', flag: '🇨🇳', country: '中国'),
  AppLanguage(code: 'ar', name: 'العربية', nativeName: 'العربية', flag: '🇸🇦', country: 'السعودية'),
  AppLanguage(code: 'tr', name: 'Türkçe', nativeName: 'Türkçe', flag: '🇹🇷', country: 'Türkiye'),
  AppLanguage(code: 'de', name: 'Deutsch', nativeName: 'Deutsch', flag: '🇩🇪', country: 'Deutschland'),
  AppLanguage(code: 'fr', name: 'Français', nativeName: 'Français', flag: '🇫🇷', country: 'France'),
  AppLanguage(code: 'es', name: 'Español', nativeName: 'Español', flag: '🇪🇸', country: 'España'),
  AppLanguage(code: 'it', name: 'Italiano', nativeName: 'Italiano', flag: '🇮🇹', country: 'Italia'),
  AppLanguage(code: 'pt', name: 'Português', nativeName: 'Português', flag: '🇵🇹', country: 'Portugal'),
  AppLanguage(code: 'hi', name: 'हिन्दी', nativeName: 'हिन्दी', flag: '🇮🇳', country: 'भारत'),
  AppLanguage(code: 'id', name: 'Bahasa Indonesia', nativeName: 'Bahasa Indonesia', flag: '🇮🇩', country: 'Indonesia'),
  AppLanguage(code: 'ms', name: 'Bahasa Melayu', nativeName: 'Bahasa Melayu', flag: '🇲🇾', country: 'Malaysia'),
  AppLanguage(code: 'th', name: 'ไทย', nativeName: 'ภาษาไทย', flag: '🇹🇭', country: 'ไทย'),
  AppLanguage(code: 'vi', name: 'Tiếng Việt', nativeName: 'Tiếng Việt', flag: '🇻🇳', country: 'Việt Nam'),
  AppLanguage(code: 'kk', name: 'Қазақша', nativeName: 'Қазақ тілі', flag: '🇰🇿', country: 'Қазақстан'),
  AppLanguage(code: 'ky', name: 'Кыргызча', nativeName: 'Кыргыз тили', flag: '🇰🇾', country: 'Кыргызстан'),
  AppLanguage(code: 'tg', name: 'Тоҷикӣ', nativeName: 'Забони тоҷикӣ', flag: '🇹🇯', country: 'Тоҷикистон'),
  AppLanguage(code: 'tk', name: 'Türkmençe', nativeName: 'Türkmen dili', flag: '🇹🇲', country: 'Türkmenistan'),
  AppLanguage(code: 'az', name: 'Azərbaycan', nativeName: 'Azərbaycan dili', flag: '🇿🇦', country: 'Azərbaycan'),
  AppLanguage(code: 'uk', name: 'Українська', nativeName: 'Українська мова', flag: '🇺🇦', country: 'Україна'),
  AppLanguage(code: 'pl', name: 'Polski', nativeName: 'Polski', flag: '🇵🇱', country: 'Polska'),
  AppLanguage(code: 'nl', name: 'Nederlands', nativeName: 'Nederlands', flag: '🇳🇱', country: 'Nederland'),
  AppLanguage(code: 'sv', name: 'Svenska', nativeName: 'Svenska', flag: '🇸🇪', country: 'Sverige'),
  AppLanguage(code: 'fi', name: 'Suomi', nativeName: 'Suomi', flag: '🇫🇮', country: 'Suomi'),
  AppLanguage(code: 'no', name: 'Norsk', nativeName: 'Norsk', flag: '🇳🇴', country: 'Norge'),
  AppLanguage(code: 'da', name: 'Dansk', nativeName: 'Dansk', flag: '🇩🇰', country: 'Danmark'),
  AppLanguage(code: 'el', name: 'Ελληνικά', nativeName: 'Ελληνικά', flag: '🇬🇷', country: 'Ελλάδα'),
  AppLanguage(code: 'he', name: 'עברית', nativeName: 'עברית', flag: '🇮🇱', country: 'ישראל'),
  AppLanguage(code: 'fa', name: 'فارسی', nativeName: 'فارسی', flag: '🇮🇷', country: 'ایران'),
  AppLanguage(code: 'ur', name: 'اردو', nativeName: 'اردو', flag: '🇵🇰', country: 'پاکستان'),
  AppLanguage(code: 'bn', name: 'বাংলা', nativeName: 'বাংলা', flag: '🇧🇩', country: 'বাংলাদেশ'),
  AppLanguage(code: 'ta', name: 'தமிழ்', nativeName: 'தமிழ்', flag: '🇮🇳', country: 'India'),
  AppLanguage(code: 'ro', name: 'Română', nativeName: 'Română', flag: '🇷🇴', country: 'România'),
  AppLanguage(code: 'hu', name: 'Magyar', nativeName: 'Magyar', flag: '🇭🇺', country: 'Magyarország'),
  AppLanguage(code: 'cs', name: 'Čeština', nativeName: 'Čeština', flag: '🇨🇿', country: 'Česko'),
  AppLanguage(code: 'sk', name: 'Slovenčina', nativeName: 'Slovenčina', flag: '🇸🇰', country: 'Slovensko'),
  AppLanguage(code: 'bg', name: 'Български', nativeName: 'Български', flag: '🇧🇬', country: 'България'),
  AppLanguage(code: 'sr', name: 'Српски', nativeName: 'Српски', flag: '🇷🇸', country: 'Србија'),
  AppLanguage(code: 'hr', name: 'Hrvatski', nativeName: 'Hrvatski', flag: '🇭🇷', country: 'Hrvatska'),
  AppLanguage(code: 'ka', name: 'ქართული', nativeName: 'ქართული', flag: '🇬🇪', country: 'საქართველო'),
  AppLanguage(code: 'hy', name: 'Հայերեն', nativeName: 'Հայերեն', flag: '🇦🇲', country: 'Հայաստան'),
];

List<AppLanguage> languagesMatching(String query) {
  final q = query.trim().toLowerCase();
  final filtered = q.isEmpty
      ? kSupportedLanguages
      : kSupportedLanguages.where((l) {
          return l.code.contains(q) ||
              l.name.toLowerCase().contains(q) ||
              l.nativeName.toLowerCase().contains(q) ||
              l.country.toLowerCase().contains(q);
        });
  final list = List<AppLanguage>.from(filtered);
  list.sort((a, b) {
    final au = a.isUnlocked ? 0 : 1;
    final bu = b.isUnlocked ? 0 : 1;
    return au.compareTo(bu);
  });
  return list;
}
