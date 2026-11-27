// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get navHome => 'होम';

  @override
  String get navLearn => 'सीखें';

  @override
  String get navTests => 'टेस्ट';

  @override
  String get navCurrentAffairs => 'करंट अफेयर्स';

  @override
  String get navResults => 'परिणाम';

  @override
  String get navProfile => 'प्रोफ़ाइल';

  @override
  String get navMenu => 'मेन्यू';

  @override
  String get appLanguage => 'ऐप की भाषा';

  @override
  String get appLanguageHelp =>
      'मेन्यू, बटन और स्क्रीन के टेक्स्ट के लिए। अनुवाद पूरा होने तक कुछ स्क्रीन अभी अंग्रेज़ी में हैं।';

  @override
  String get alsoUseForQuestions => 'प्रश्न भी इसी भाषा में दिखाएँ';

  @override
  String get questionLanguage => 'प्रश्नों की भाषा';

  @override
  String get languageSaveFailed => 'इस डिवाइस पर भाषा सेव नहीं हो सकी।';

  @override
  String get bookmarksTitle => 'बुकमार्क';

  @override
  String bookmarksCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सेव किए गए प्रश्न · इस डिवाइस पर',
      one: '1 सेव किया गया प्रश्न · इस डिवाइस पर',
    );
    return '$_temp0';
  }

  @override
  String get bookmarksAll => 'सभी';

  @override
  String get bookmarksEmptyTitle => 'अभी कोई प्रश्न सेव नहीं है';

  @override
  String get bookmarksEmptyBody =>
      'टेस्ट की समीक्षा करते समय किसी भी प्रश्न पर बुकमार्क आइकन दबाएँ, वह हल के साथ यहाँ सेव हो जाएगा।';

  @override
  String get bookmarkRemoved => 'यह बुकमार्क हटा दिया गया।';

  @override
  String get savedQuestion => 'सेव किया गया प्रश्न';

  @override
  String get removeBookmark => 'बुकमार्क हटाएँ';

  @override
  String get bookmarkQuestion => 'इस प्रश्न को बुकमार्क करें';

  @override
  String get savedToBookmarks => 'बुकमार्क में सेव किया गया';

  @override
  String get removedFromBookmarks => 'बुकमार्क से हटाया गया';

  @override
  String get bookmarkSaveFailed =>
      'यह प्रश्न सेव नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get view => 'देखें';

  @override
  String get solution => 'हल';

  @override
  String get correctAnswer => 'सही उत्तर';

  @override
  String get yourAnswer => 'आपका उत्तर';

  @override
  String get correctYourAnswer => 'सही · आपका उत्तर';

  @override
  String get savedToday => 'आज सेव किया';

  @override
  String get savedYesterday => 'कल सेव किया';

  @override
  String savedDaysAgo(int days) {
    return '$days दिन पहले सेव किया';
  }

  @override
  String get offlineTitle => 'डाउनलोड और ऑफ़लाइन';

  @override
  String get offlineIntro => 'इस फ़ोन पर बिना इंटरनेट उपलब्ध';

  @override
  String get offlineSavedQuestions => 'सेव किए गए प्रश्न';

  @override
  String get offlineSavedQuestionsEmpty =>
      'टेस्ट की समीक्षा करते समय प्रश्न बुकमार्क करें';

  @override
  String offlineSavedQuestionsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'हल सहित $count प्रश्न',
      one: 'हल सहित 1 प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String get offlineRevision => 'दोहराव सूची';

  @override
  String get offlineRevisionEmpty =>
      'आपके गलत प्रश्न दोहराने के लिए यहाँ जुड़ते हैं';

  @override
  String offlineRevisionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'आपकी पिछली गलतियों से $count प्रश्न',
      one: 'आपकी पिछली गलतियों से 1 प्रश्न',
    );
    return '$_temp0';
  }

  @override
  String get offlineTestsTitle =>
      'टेस्ट शुरू और सबमिट करने के लिए इंटरनेट चाहिए';

  @override
  String get offlineTestsBody =>
      'टेस्ट के दौरान इंटरनेट चला जाए तो आपके उत्तर इस फ़ोन पर सेव रहते हैं और ऑनलाइन होने पर आप जारी रख सकते हैं। पूरे टेस्ट और नोट्स अभी डाउनलोड नहीं किए जा सकते।';

  @override
  String get profileDownloads => 'डाउनलोड और ऑफ़लाइन';

  @override
  String get profileBookmarks => 'बुकमार्क';

  @override
  String get profilePrivacy => 'गोपनीयता और खाता';

  @override
  String get profilePrivacySubtitle => 'खाता नियंत्रण और गोपनीयता सेटिंग';

  @override
  String get retry => 'फिर से कोशिश करें';
}
