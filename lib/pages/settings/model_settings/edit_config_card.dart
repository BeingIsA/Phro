import 'package:flutter/material.dart';
import 'package:phro/services/model_config_service.dart';

/// 模型设置组件（URL、模型名称、API Key + 保存按钮）
class EditModelConfigCard extends StatefulWidget {
  final String? id;

  const EditModelConfigCard({super.key, this.id});

  @override
  State<EditModelConfigCard> createState() => _EditModelConfigCardState();
}

class _EditModelConfigCardState extends State<EditModelConfigCard> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final modelConfigService = ModelConfigService.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadExistingConfig();
    }
  }

  Future<void> _loadExistingConfig() async {
    final config = await modelConfigService.getConfigById(widget.id!);

    if (config != null) {
      // 同时支持对象属性和 Map 两种常见写法（任选其一，推荐根据实际 Model 统一使用）
      _nameController.text = config['configName'] ?? '';
      _urlController.text = config['url'] ?? '';
      _modelController.text = (config['modelName'] ?? config['model'] ?? '');
      _apiKeyController.text = config['apiKey'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _urlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '配置名称',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: '例如：https://api.openai.com/v1',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // ← 必填校验
                if (value == null || value.trim().isEmpty) {
                  return '必填';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: const InputDecoration(
                labelText: 'Model Name',
                hintText: '例如：gpt-4',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // ← 必填校验
                if (value == null || value.trim().isEmpty) {
                  return '必填';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: '请输入您的 API Key',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                // ← 必填校验
                if (value == null || value.trim().isEmpty) {
                  return '必填';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final name = _nameController.text;
                  final url = _urlController.text;
                  final model = _modelController.text;
                  final apiKey = _apiKeyController.text;

                  debugPrint('配置名称: $name');
                  debugPrint('URL: $url');
                  debugPrint('Model: $model');
                  debugPrint('API Key: $apiKey');
                  modelConfigService.saveConfig(
                    id: widget.id,
                    configName: name,
                    url: url,
                    modelName: model,
                    apiKey: apiKey,
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('设置已保存')));
                }
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }
}
