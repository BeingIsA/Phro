import 'package:flutter/material.dart';
import 'package:phro/widgets/app_drawer/settings/api_settings/edit_language_model_config_card.dart';
import 'package:phro/services/model_config_service.dart';

class LanguageModelConfigPage extends StatefulWidget {
  const LanguageModelConfigPage({super.key});

  @override
  State<LanguageModelConfigPage> createState() =>
      _LanguageModelConfigPageState();
}

class _LanguageModelConfigPageState extends State<LanguageModelConfigPage> {
  final ModelConfigService modelConfigService = ModelConfigService.instance;
  List<dynamic> _configs = [];
  String? _activated;

  @override
  void initState() {
    super.initState();
    _loadConfigs();
  }

  Future<void> _loadConfigs() async {
    final configs = await modelConfigService.getAllConfigs();
    final activated = await modelConfigService.getActivatedId();
    setState(() {
      _configs = configs;
      _activated = activated;
    });
  }

  Future<void> _toggleActive(String id, bool newValue) async {
    if (newValue) {
      await modelConfigService.activate(id);
    } else {
      await modelConfigService.deactivate(id);
    }
    await _loadConfigs();
  }

  Future<void> _deleteCard(String id, String configName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除配置 "$configName" 吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await modelConfigService.deleteConfig(id);
      await _loadConfigs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Table(
            columnWidths: {
              0: FixedColumnWidth(availableWidth * 0.3),
              1: FixedColumnWidth(availableWidth * 0.3),
              2: FlexColumnWidth(1),
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
              top: BorderSide(color: colorScheme.outlineVariant, width: 1),
              bottom: BorderSide(color: colorScheme.outlineVariant, width: 1),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // ==================== 表头 ====================
              TableRow(
                decoration: BoxDecoration(
                  color: colorScheme
                      .surfaceContainerHighest, // ✅ 替换 surfaceVariant
                ),
                children: [
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '配置别名',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        '模型名称',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: Icon(
                            Icons.add_circle,
                            color: colorScheme.primary,
                          ),
                          tooltip: '新增配置',
                          onPressed: () {
                            showDialog(
                              context: context,
                              useRootNavigator: false,
                              builder: (BuildContext buildContext) {
                                return const EditLanguageModelConfigCard();
                              },
                            ).then((saved) {
                              _loadConfigs();
                              if (saved == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('设置已保存')),
                                );
                              }
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // ==================== 数据行 ====================
              ..._configs.map((config) {
                final configName = config.configName as String? ?? '';
                final modelName = config.modelName as String? ?? '';
                final id = config.id as String? ?? '';

                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          configName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          modelName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    TableCell(
                      child: Align(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: colorScheme.primary,
                                ),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext buildContext) {
                                      return EditLanguageModelConfigCard(
                                        id: id,
                                      );
                                    },
                                  ).then((saved) {
                                    _loadConfigs();
                                    if (saved == true) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(content: Text('设置已保存')),
                                      );
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete,
                                  color: colorScheme.error,
                                ),
                                onPressed: () => _deleteCard(id, configName),
                              ),
                              Switch(
                                value: id == _activated,
                                onChanged: (bool newValue) {
                                  _toggleActive(id, newValue);
                                },
                                activeColor: colorScheme.primary,
                                activeTrackColor: colorScheme.primaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }
}
