import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('en'),
    Locale('zh'),
  ];

  /// No description provided for @deleteConfirmationTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Confirmation'**
  String get deleteConfirmationTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'version'**
  String get version;

  /// No description provided for @currentChatAgent.
  ///
  /// In en, this message translates to:
  /// **'Current chat agent: {agentName}'**
  String currentChatAgent(String agentName);

  /// No description provided for @newChatPrefix.
  ///
  /// In en, this message translates to:
  /// **'New chat ('**
  String get newChatPrefix;

  /// No description provided for @newChatSuffix.
  ///
  /// In en, this message translates to:
  /// **')'**
  String get newChatSuffix;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @editAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Agent'**
  String get editAgentTitle;

  /// No description provided for @newAgentTitle.
  ///
  /// In en, this message translates to:
  /// **'New Agent'**
  String get newAgentTitle;

  /// No description provided for @agentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Agent Name *'**
  String get agentNameLabel;

  /// No description provided for @agentNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., professional writing assistant'**
  String get agentNameHint;

  /// No description provided for @nameNotEmptyError.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameNotEmptyError;

  /// No description provided for @identityLabel.
  ///
  /// In en, this message translates to:
  /// **'Identity (System Prompt) *'**
  String get identityLabel;

  /// No description provided for @identityHint.
  ///
  /// In en, this message translates to:
  /// **'You are a professional...'**
  String get identityHint;

  /// No description provided for @saveChangesButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChangesButton;

  /// No description provided for @createButton.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get createButton;

  /// No description provided for @agentManagementTitle.
  ///
  /// In en, this message translates to:
  /// **'Agent Management'**
  String get agentManagementTitle;

  /// No description provided for @newAgentTooltip.
  ///
  /// In en, this message translates to:
  /// **'New Agent'**
  String get newAgentTooltip;

  /// No description provided for @editAgentTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit Agent'**
  String get editAgentTooltip;

  /// No description provided for @noAgentsText.
  ///
  /// In en, this message translates to:
  /// **'No Agents'**
  String get noAgentsText;

  /// No description provided for @toolCallResult.
  ///
  /// In en, this message translates to:
  /// **'Tool call [{name}]'**
  String toolCallResult(String name);

  /// No description provided for @toolSecurityWarning.
  ///
  /// In en, this message translates to:
  /// **'Security warning: Tool {name} requests authorization'**
  String toolSecurityWarning(String name);

  /// No description provided for @toolArgumentsPrefix.
  ///
  /// In en, this message translates to:
  /// **'Arguments: '**
  String get toolArgumentsPrefix;

  /// No description provided for @toolRejected.
  ///
  /// In en, this message translates to:
  /// **'Tool {name} has been rejected'**
  String toolRejected(String name);

  /// No description provided for @toolStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Status: Waiting for security authorization...'**
  String get toolStatusPending;

  /// No description provided for @toolStatusRejectedPrefix.
  ///
  /// In en, this message translates to:
  /// **'Rejection details:\n'**
  String get toolStatusRejectedPrefix;

  /// No description provided for @toolStatusResultPrefix.
  ///
  /// In en, this message translates to:
  /// **'Call result:'**
  String get toolStatusResultPrefix;

  /// No description provided for @toolReasonHint.
  ///
  /// In en, this message translates to:
  /// **'Enter rejection reason or correction feedback (optional)...'**
  String get toolReasonHint;

  /// No description provided for @rejectButton.
  ///
  /// In en, this message translates to:
  /// **'Reject'**
  String get rejectButton;

  /// No description provided for @allowButton.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allowButton;

  /// No description provided for @startNewChatText.
  ///
  /// In en, this message translates to:
  /// **'Start a new conversation!'**
  String get startNewChatText;

  /// No description provided for @thinkingProcessTitle.
  ///
  /// In en, this message translates to:
  /// **'Thinking process'**
  String get thinkingProcessTitle;

  /// No description provided for @chatHistoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistoryTitle;

  /// No description provided for @noChatHistoryText.
  ///
  /// In en, this message translates to:
  /// **'No history conversations'**
  String get noChatHistoryText;

  /// No description provided for @editButton.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editButton;

  /// No description provided for @deleteButton.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteButton;

  /// No description provided for @editChatTitleTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Title'**
  String get editChatTitleTitle;

  /// No description provided for @editChatTitleHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter new title'**
  String get editChatTitleHint;

  /// No description provided for @cancelButtonMsg.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancelButtonMsg;

  /// No description provided for @saveButton.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveButton;

  /// No description provided for @deleteChatConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are yous sure you want to delete session {title}? This operation cannot be undone.'**
  String deleteChatConfirmation(String title);

  /// No description provided for @editMessageTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit message'**
  String get editMessageTooltip;

  /// No description provided for @resendButton.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resendButton;

  /// No description provided for @messageInputHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter content...'**
  String get messageInputHint;

  /// No description provided for @configAliasTitle.
  ///
  /// In en, this message translates to:
  /// **'Config Alias'**
  String get configAliasTitle;

  /// No description provided for @modelNameTitle.
  ///
  /// In en, this message translates to:
  /// **'Model Name'**
  String get modelNameTitle;

  /// No description provided for @addConfigTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add Config'**
  String get addConfigTooltip;

  /// No description provided for @settingsSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Settings saved'**
  String get settingsSavedMessage;

  /// No description provided for @configNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Config Name'**
  String get configNameLabel;

  /// No description provided for @urlExampleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., https://api.openai.com/v1'**
  String get urlExampleHint;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @apiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'Please enter your API Key'**
  String get apiKeyHint;

  /// No description provided for @searchApiConfigSavedMessage.
  ///
  /// In en, this message translates to:
  /// **'Search API configuration saved'**
  String get searchApiConfigSavedMessage;

  /// No description provided for @searchApiConfigSaveError.
  ///
  /// In en, this message translates to:
  /// **'Save failed: {error}'**
  String searchApiConfigSaveError(String error);

  /// No description provided for @apiKeyLabel.
  ///
  /// In en, this message translates to:
  /// **'API Key'**
  String get apiKeyLabel;

  /// No description provided for @searchApiConfigTitle.
  ///
  /// In en, this message translates to:
  /// **'Search API Config'**
  String get searchApiConfigTitle;

  /// No description provided for @searchApiSupportedEngines.
  ///
  /// In en, this message translates to:
  /// **'Supports Tavily / Firecrawl'**
  String get searchApiSupportedEngines;

  /// No description provided for @urlRequiredError.
  ///
  /// In en, this message translates to:
  /// **'URL cannot be empty'**
  String get urlRequiredError;

  /// No description provided for @apiKeyRequiredError.
  ///
  /// In en, this message translates to:
  /// **'API Key cannot be empty'**
  String get apiKeyRequiredError;

  /// No description provided for @saveSearchApiConfigButton.
  ///
  /// In en, this message translates to:
  /// **'Save Config'**
  String get saveSearchApiConfigButton;

  /// No description provided for @languageModelMenu.
  ///
  /// In en, this message translates to:
  /// **'Language Model'**
  String get languageModelMenu;

  /// No description provided for @visionModelMenu.
  ///
  /// In en, this message translates to:
  /// **'Vision Model'**
  String get visionModelMenu;

  /// No description provided for @speechModelMenu.
  ///
  /// In en, this message translates to:
  /// **'Speech Model'**
  String get speechModelMenu;

  /// No description provided for @searchApiMenu.
  ///
  /// In en, this message translates to:
  /// **'Search API'**
  String get searchApiMenu;

  /// No description provided for @otherSettingsMenu.
  ///
  /// In en, this message translates to:
  /// **'Other Settings'**
  String get otherSettingsMenu;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @languageModelAppBar.
  ///
  /// In en, this message translates to:
  /// **'Language Model'**
  String get languageModelAppBar;

  /// No description provided for @visionModelAppBar.
  ///
  /// In en, this message translates to:
  /// **'Vision Model'**
  String get visionModelAppBar;

  /// No description provided for @speechModelAppBar.
  ///
  /// In en, this message translates to:
  /// **'Speech Model'**
  String get speechModelAppBar;

  /// No description provided for @searchApiAppBar.
  ///
  /// In en, this message translates to:
  /// **'Search API'**
  String get searchApiAppBar;

  /// No description provided for @otherSettingsAppBar.
  ///
  /// In en, this message translates to:
  /// **'Other Settings'**
  String get otherSettingsAppBar;

  /// No description provided for @urlLabel.
  ///
  /// In en, this message translates to:
  /// **'URL'**
  String get urlLabel;

  /// No description provided for @modelNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., gpt-4'**
  String get modelNameHint;

  /// No description provided for @apiEndpointUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'API Endpoint URL'**
  String get apiEndpointUrlLabel;

  /// No description provided for @searchApiKeyHint.
  ///
  /// In en, this message translates to:
  /// **'tvly-xxxx or fc-xxxx'**
  String get searchApiKeyHint;

  /// No description provided for @deleteConfigConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete config \"{configName}\"? This operation cannot be undone.'**
  String deleteConfigConfirmation(String configName);

  /// No description provided for @visionModelComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Vision model configuration\nComing soon...'**
  String get visionModelComingSoon;

  /// No description provided for @speechModelComingSoon.
  ///
  /// In en, this message translates to:
  /// **'Speech model configuration\nComing soon...'**
  String get speechModelComingSoon;

  /// No description provided for @languageNameChinese.
  ///
  /// In en, this message translates to:
  /// **'简体中文'**
  String get languageNameChinese;

  /// No description provided for @languageNameEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageNameEnglish;

  /// No description provided for @languageNameJapanese.
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageNameJapanese;
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
      <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
