import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';
import 'app_localizations_om.dart';
import 'app_localizations_ti.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en'),
    Locale('om'),
    Locale('ti'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Oromia Communication Bureau'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @languageSelect.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get languageSelect;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @continueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue as Guest'**
  String get continueAsGuest;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @news.
  ///
  /// In en, this message translates to:
  /// **'News'**
  String get news;

  /// No description provided for @tenders.
  ///
  /// In en, this message translates to:
  /// **'Tenders'**
  String get tenders;

  /// No description provided for @government.
  ///
  /// In en, this message translates to:
  /// **'Government'**
  String get government;

  /// No description provided for @media.
  ///
  /// In en, this message translates to:
  /// **'Media'**
  String get media;

  /// No description provided for @kallachaOromia.
  ///
  /// In en, this message translates to:
  /// **'Kallacha Oromia'**
  String get kallachaOromia;

  /// No description provided for @shop.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shop;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @politics.
  ///
  /// In en, this message translates to:
  /// **'Politics'**
  String get politics;

  /// No description provided for @social.
  ///
  /// In en, this message translates to:
  /// **'Social'**
  String get social;

  /// No description provided for @economy.
  ///
  /// In en, this message translates to:
  /// **'Economy'**
  String get economy;

  /// No description provided for @sport.
  ///
  /// In en, this message translates to:
  /// **'Sport'**
  String get sport;

  /// No description provided for @technology.
  ///
  /// In en, this message translates to:
  /// **'Technology'**
  String get technology;

  /// No description provided for @environment.
  ///
  /// In en, this message translates to:
  /// **'Environment'**
  String get environment;

  /// No description provided for @features.
  ///
  /// In en, this message translates to:
  /// **'Features'**
  String get features;

  /// No description provided for @pressRelease.
  ///
  /// In en, this message translates to:
  /// **'Press Release'**
  String get pressRelease;

  /// No description provided for @documentary.
  ///
  /// In en, this message translates to:
  /// **'Documentary'**
  String get documentary;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @imageGallery.
  ///
  /// In en, this message translates to:
  /// **'Image & Gallery'**
  String get imageGallery;

  /// No description provided for @audioFiles.
  ///
  /// In en, this message translates to:
  /// **'Audio Files'**
  String get audioFiles;

  /// No description provided for @weeklyNewspaper.
  ///
  /// In en, this message translates to:
  /// **'Weekly Newspaper'**
  String get weeklyNewspaper;

  /// No description provided for @quarterlyNewspaper.
  ///
  /// In en, this message translates to:
  /// **'Quarterly Newspaper'**
  String get quarterlyNewspaper;

  /// No description provided for @yearlyBook.
  ///
  /// In en, this message translates to:
  /// **'Yearly Book'**
  String get yearlyBook;

  /// No description provided for @brochure.
  ///
  /// In en, this message translates to:
  /// **'Brochure'**
  String get brochure;

  /// No description provided for @archive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get archive;

  /// No description provided for @filesAndBooks.
  ///
  /// In en, this message translates to:
  /// **'Files & Books'**
  String get filesAndBooks;

  /// No description provided for @regionalSectors.
  ///
  /// In en, this message translates to:
  /// **'Regional Sectors'**
  String get regionalSectors;

  /// No description provided for @zone.
  ///
  /// In en, this message translates to:
  /// **'Zone'**
  String get zone;

  /// No description provided for @woreda.
  ///
  /// In en, this message translates to:
  /// **'Woreda'**
  String get woreda;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @subCity.
  ///
  /// In en, this message translates to:
  /// **'Sub-City'**
  String get subCity;

  /// No description provided for @kebele.
  ///
  /// In en, this message translates to:
  /// **'Kebele'**
  String get kebele;

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @contactUs.
  ///
  /// In en, this message translates to:
  /// **'Contact Us'**
  String get contactUs;

  /// No description provided for @recentNews.
  ///
  /// In en, this message translates to:
  /// **'Recent News'**
  String get recentNews;

  /// No description provided for @ourRecentNews.
  ///
  /// In en, this message translates to:
  /// **'Our Recent News'**
  String get ourRecentNews;

  /// No description provided for @veryMuchRead.
  ///
  /// In en, this message translates to:
  /// **'Very Much Read'**
  String get veryMuchRead;

  /// No description provided for @mostRecent.
  ///
  /// In en, this message translates to:
  /// **'Most Recent'**
  String get mostRecent;

  /// No description provided for @mostRead.
  ///
  /// In en, this message translates to:
  /// **'Most Read'**
  String get mostRead;

  /// No description provided for @viewMore.
  ///
  /// In en, this message translates to:
  /// **'View More'**
  String get viewMore;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get seeAll;

  /// No description provided for @views.
  ///
  /// In en, this message translates to:
  /// **'views'**
  String get views;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @relatedNews.
  ///
  /// In en, this message translates to:
  /// **'Related News'**
  String get relatedNews;

  /// No description provided for @addToCart.
  ///
  /// In en, this message translates to:
  /// **'Add to Cart'**
  String get addToCart;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @emptyCart.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get emptyCart;

  /// No description provided for @emptyNews.
  ///
  /// In en, this message translates to:
  /// **'No news found'**
  String get emptyNews;

  /// No description provided for @emptyTenders.
  ///
  /// In en, this message translates to:
  /// **'No tenders available'**
  String get emptyTenders;

  /// No description provided for @emptyMedia.
  ///
  /// In en, this message translates to:
  /// **'No media available'**
  String get emptyMedia;

  /// No description provided for @emptyPublications.
  ///
  /// In en, this message translates to:
  /// **'No publications available'**
  String get emptyPublications;

  /// No description provided for @emptyProducts.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get emptyProducts;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @deadline.
  ///
  /// In en, this message translates to:
  /// **'Deadline'**
  String get deadline;

  /// No description provided for @viewDocument.
  ///
  /// In en, this message translates to:
  /// **'View Document'**
  String get viewDocument;

  /// No description provided for @subscribe.
  ///
  /// In en, this message translates to:
  /// **'Subscribe'**
  String get subscribe;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailHint;

  /// No description provided for @copyright.
  ///
  /// In en, this message translates to:
  /// **'© 2026 Oromia Communication Bureau. All rights reserved.'**
  String get copyright;

  /// No description provided for @missionStatement.
  ///
  /// In en, this message translates to:
  /// **'Effective communication for Oromia Prosperity'**
  String get missionStatement;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Bole Dembel, Finfinnee (Addis Ababa), Ethiopia'**
  String get address;

  /// No description provided for @phone1.
  ///
  /// In en, this message translates to:
  /// **'+251115541816'**
  String get phone1;

  /// No description provided for @phone2.
  ///
  /// In en, this message translates to:
  /// **'+251115541801'**
  String get phone2;

  /// No description provided for @contactEmail.
  ///
  /// In en, this message translates to:
  /// **'info@oromiacommunication.gov.et'**
  String get contactEmail;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @amharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get amharic;

  /// No description provided for @afaanOromo.
  ///
  /// In en, this message translates to:
  /// **'Afaan Oromo'**
  String get afaanOromo;

  /// No description provided for @tigrigna.
  ///
  /// In en, this message translates to:
  /// **'Tigrigna'**
  String get tigrigna;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['am', 'en', 'om', 'ti'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
    case 'om':
      return AppLocalizationsOm();
    case 'ti':
      return AppLocalizationsTi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
