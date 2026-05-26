import 'package:flutter/material.dart';
import 'package:phro/pages/settings/api_settings/edit_language_model_config_card.dart';
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
      _configs = configs; // 原有代码
      _activated = activated; // ← 新增这一行
    });
  }

  Future<void> _toggleActive(String id, bool newValue) async {
    if (newValue) {
      await modelConfigService.activate(id);
    } else {
      await modelConfigService.deactivate(id);
    }
    await _loadConfigs(); // 切换后刷新列表
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
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await modelConfigService.deleteConfig(id);
      await _loadConfigs(); // 刷新列表
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical, // 纵向滚动
      child: DataTable(
        headingRowColor: WidgetStateColor.resolveWith(
          (states) => Colors.grey.shade100, // 可选：表头单独颜色
        ),
        columns: [
          DataColumn(
            label: Text('配置别名', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('模型名称', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: IconButton(
              icon: Icon(Icons.add_circle, color: Colors.blue),
              tooltip: '新增配置',
              onPressed: () {
                showDialog(
                  context: context,
                  useRootNavigator: false,
                  builder: (BuildContext buildContext) {
                    return EditLanguageModelConfigCard();
                  },
                ).then((saved) {
                  _loadConfigs();
                  if (saved == true) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(const SnackBar(content: Text('设置已保存')));
                  }
                });
              },
            ),
          ),
        ],
        rows: _configs.map((config) {
          final configName = config.configName as String? ?? '';
          final modelName = config.modelName as String? ?? '';
          final id = config.id as String? ?? '';
          return DataRow(
            cells: [
              DataCell(Text(configName)),
              DataCell(Text(modelName)),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext buildContext) {
                            return EditLanguageModelConfigCard(id: id);
                          },
                        ).then((saved) {
                          _loadConfigs(); // 编辑完成后也刷新
                          if (saved == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('设置已保存')),
                            );
                          }
                        });
                      },
                    ),
                    // 删除按钮
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteCard(id, configName),
                    ),
                    Switch(
                      value: id == _activated,
                      onChanged: (bool newValue) {
                        _toggleActive(id, newValue);
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('设置已保存')));
                      },
                      activeThumbColor: Colors.green,
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
