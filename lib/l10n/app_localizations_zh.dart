// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get deleteConfirmationTitle => '删除确认';

  @override
  String get cancel => '取消';

  @override
  String get delete => '删除';

  @override
  String get language => '语言';

  @override
  String get version => '版本';

  @override
  String currentChatAgent(String agentName) {
    return '当前对话Agent：$agentName';
  }

  @override
  String get newChatPrefix => '新对话（';

  @override
  String get newChatSuffix => ')';

  @override
  String get settings => '设置';

  @override
  String get editAgentTitle => '编辑 Agent';

  @override
  String get newAgentTitle => '新建 Agent';

  @override
  String get agentNameLabel => 'Agent 名称 *';

  @override
  String get agentNameHint => '例如：专业写作助手';

  @override
  String get nameNotEmptyError => '名称不能为空';

  @override
  String get identityLabel => 'Identity（系统提示词） *';

  @override
  String get identityHint => '你是一个专业的...';

  @override
  String get saveChangesButton => '保存修改';

  @override
  String get createButton => '创建';

  @override
  String get agentManagementTitle => 'Agent管理';

  @override
  String get newAgentTooltip => '新建 Agent';

  @override
  String get editAgentTooltip => '编辑 Agent';

  @override
  String get noAgentsText => '暂无 Agent';

  @override
  String toolCallResult(String name) {
    return '工具 $name 调用结果';
  }

  @override
  String toolSecurityWarning(String name) {
    return '安全警告：工具 $name 请求授权';
  }

  @override
  String get toolArgumentsPrefix => '参数：';

  @override
  String toolRejected(String name) {
    return '工具 $name 已被拒绝';
  }

  @override
  String get toolStatusPending => '状态：等待安全授权...';

  @override
  String get toolStatusRejectedPrefix => '拒绝详情：\n';

  @override
  String get toolStatusResultPrefix => '调用结果：\n';

  @override
  String get toolReasonHint => '输入拒绝原因或修正反馈（可选）...';

  @override
  String get rejectButton => '拒绝';

  @override
  String get allowButton => '允许';

  @override
  String get startNewChatText => '开始新的对话吧！';

  @override
  String get thinkingProcessTitle => '思考过程';

  @override
  String get chatHistoryTitle => '聊天历史';

  @override
  String get noChatHistoryText => '暂无历史对话';

  @override
  String get editButton => '编辑';

  @override
  String get deleteButton => '删除';

  @override
  String get editChatTitleTitle => '编辑标题';

  @override
  String get editChatTitleHint => '请输入新标题';

  @override
  String get cancelButtonMsg => '取消';

  @override
  String get saveButton => '保存';

  @override
  String deleteChatConfirmation(String title) {
    return '确定删除会话 \"$title\" 吗？此操作无法撤销。';
  }

  @override
  String get editMessageTooltip => '编辑消息';

  @override
  String get resendButton => '重新发送';

  @override
  String get messageInputHint => '请输入内容...';

  @override
  String get configAliasTitle => '配置别名';

  @override
  String get modelNameTitle => '模型名称';

  @override
  String get addConfigTooltip => '新增配置';

  @override
  String get settingsSavedMessage => '设置已保存';

  @override
  String get configNameLabel => '配置名称';

  @override
  String get urlExampleHint => '例如：https://api.openai.com/v1';

  @override
  String get requiredField => '必填';

  @override
  String get apiKeyHint => '请输入您的 API Key';

  @override
  String get searchApiConfigSavedMessage => '搜索API 配置已保存';

  @override
  String searchApiConfigSaveError(String error) {
    return '保存失败: $error';
  }

  @override
  String get searchApiConfigTitle => '搜索API 配置';

  @override
  String get searchApiSupportedEngines => '支持 Tavily / Firecrawl';

  @override
  String get urlRequiredError => 'URL 不能为空';

  @override
  String get apiKeyRequiredError => 'API Key 不能为空';

  @override
  String get saveSearchApiConfigButton => '保存配置';

  @override
  String get languageModelMenu => '语言模型';

  @override
  String get visionModelMenu => '视觉模型';

  @override
  String get speechModelMenu => '语音模型';

  @override
  String get searchApiMenu => '搜索API';

  @override
  String get otherSettingsMenu => '其他设置';

  @override
  String get settingsTitle => '设置';

  @override
  String get languageModelAppBar => '语言模型';

  @override
  String get visionModelAppBar => '视觉模型';

  @override
  String get speechModelAppBar => '语音模型';

  @override
  String get searchApiAppBar => '搜索API';

  @override
  String get otherSettingsAppBar => '其他设置';
}
