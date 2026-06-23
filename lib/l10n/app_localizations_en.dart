// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get deleteConfirmationTitle => 'Delete Confirmation';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get language => 'Language';

  @override
  String get version => 'version';

  @override
  String currentChatAgent(String agentName) {
    return 'Current chat agent: $agentName';
  }

  @override
  String get newChatPrefix => 'New chat (';

  @override
  String get newChatSuffix => ')';

  @override
  String get settings => 'Settings';

  @override
  String get editAgentTitle => 'Edit Agent';

  @override
  String get newAgentTitle => 'New Agent';

  @override
  String get agentNameLabel => 'Agent Name *';

  @override
  String get agentNameHint => 'e.g., professional writing assistant';

  @override
  String get nameNotEmptyError => 'Name cannot be empty';

  @override
  String get identityLabel => 'Identity (System Prompt) *';

  @override
  String get identityHint => 'You are a professional...';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get createButton => 'Create';

  @override
  String get agentManagementTitle => 'Agent Management';

  @override
  String get newAgentTooltip => 'New Agent';

  @override
  String get editAgentTooltip => 'Edit Agent';

  @override
  String get noAgentsText => 'No Agents';

  @override
  String toolCallFinished(String name) {
    return 'Tool call [$name] finished';
  }

  @override
  String toolExecuting(String name) {
    return 'Tool [$name] executing';
  }

  @override
  String toolSecurityWarning(String name) {
    return 'Security warning: Tool $name requests authorization';
  }

  @override
  String get toolArgumentsPrefix => 'Arguments: ';

  @override
  String toolRejected(String name) {
    return 'Tool $name has been rejected';
  }

  @override
  String toolCanceled(String name) {
    return 'Tool $name has been canceled';
  }

  @override
  String get toolStatusPending =>
      'Status: Waiting for security authorization...';

  @override
  String get toolStatusRejected => 'Rejection details:';

  @override
  String get toolStatusfinished => 'Call result:';

  @override
  String get toolStatusExecuting => 'Executing...';

  @override
  String get toolReasonHint =>
      'Enter rejection reason or correction feedback (optional)...';

  @override
  String get rejectButton => 'Reject';

  @override
  String get allowButton => 'Allow';

  @override
  String get startNewChatText => 'Start a new conversation!';

  @override
  String get thinkingProcessTitle => 'Thinking process';

  @override
  String get chatHistoryTitle => 'Chat History';

  @override
  String get noChatHistoryText => 'No history conversations';

  @override
  String get editButton => 'Edit';

  @override
  String get deleteButton => 'Delete';

  @override
  String get editChatTitleTitle => 'Edit Title';

  @override
  String get editChatTitleHint => 'Please enter new title';

  @override
  String get cancelButtonMsg => 'Cancel';

  @override
  String get saveButton => 'Save';

  @override
  String deleteChatConfirmation(String title) {
    return 'Are yous sure you want to delete session $title? This operation cannot be undone.';
  }

  @override
  String get editMessageTooltip => 'Edit message';

  @override
  String get resendButton => 'Resend';

  @override
  String get messageInputHint => 'Please enter content...';

  @override
  String get sendTooltip => 'Send';

  @override
  String get stopGenerationTooltip => 'Stop generating';

  @override
  String get configAliasTitle => 'Config Alias';

  @override
  String get modelNameTitle => 'Model Name';

  @override
  String get addConfigTooltip => 'Add Config';

  @override
  String get settingsSavedMessage => 'Settings saved';

  @override
  String get configNameLabel => 'Config Name';

  @override
  String get urlExampleHint => 'e.g., https://api.openai.com/v1';

  @override
  String get requiredField => 'Required';

  @override
  String get apiKeyHint => 'Please enter your API Key';

  @override
  String get searchApiConfigSavedMessage => 'Search API configuration saved';

  @override
  String searchApiConfigSaveError(String error) {
    return 'Save failed: $error';
  }

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get searchApiConfigTitle => 'Search API Config';

  @override
  String get searchApiSupportedEngines => 'Supports Tavily / Firecrawl';

  @override
  String get urlRequiredError => 'URL cannot be empty';

  @override
  String get apiKeyRequiredError => 'API Key cannot be empty';

  @override
  String get saveSearchApiConfigButton => 'Save Config';

  @override
  String get languageModelMenu => 'Language Model';

  @override
  String get visionModelMenu => 'Vision Model';

  @override
  String get speechModelMenu => 'Speech Model';

  @override
  String get searchApiMenu => 'Search API';

  @override
  String get otherSettingsMenu => 'Other Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get languageModelAppBar => 'Language Model';

  @override
  String get visionModelAppBar => 'Vision Model';

  @override
  String get speechModelAppBar => 'Speech Model';

  @override
  String get searchApiAppBar => 'Search API';

  @override
  String get otherSettingsAppBar => 'Other Settings';

  @override
  String get urlLabel => 'URL';

  @override
  String get modelNameHint => 'e.g., gpt-4';

  @override
  String get apiEndpointUrlLabel => 'API Endpoint URL';

  @override
  String get searchApiKeyHint => 'tvly-xxxx or fc-xxxx';

  @override
  String deleteConfigConfirmation(String configName) {
    return 'Are you sure you want to delete config \"$configName\"? This operation cannot be undone.';
  }

  @override
  String get visionModelComingSoon =>
      'Vision model configuration\nComing soon...';

  @override
  String get speechModelComingSoon =>
      'Speech model configuration\nComing soon...';

  @override
  String get languageNameChinese => '简体中文';

  @override
  String get languageNameEnglish => 'English';

  @override
  String get languageNameJapanese => '日本語';
}
