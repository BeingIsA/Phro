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
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth; // 关键：获取实际可用宽度

        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Table(
            columnWidths: {
              0: FixedColumnWidth(availableWidth * 0.3), // 配置别名
              1: FixedColumnWidth(availableWidth * 0.3), // 模型名称
              2: FlexColumnWidth(1), // 操作列占剩余空间
            },
            border: TableBorder(
              horizontalInside: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
              top: BorderSide(color: Colors.grey.shade300, width: 1),
              bottom: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // ==================== 表头 ====================
              TableRow(
                decoration: const BoxDecoration(color: Colors.grey),
                children: [
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '配置别名',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        '模型名称',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          icon: const Icon(
                            Icons.add_circle,
                            color: Colors.blue,
                          ),
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
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
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
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => _deleteCard(id, configName),
                              ),
                              Switch(
                                value: id == _activated,
                                onChanged: (bool newValue) {
                                  _toggleActive(id, newValue);
                                },
                                activeThumbColor: Colors.green,
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
