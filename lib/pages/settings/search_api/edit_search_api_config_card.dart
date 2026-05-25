import 'package:flutter/material.dart';
import 'package:phro/services/config/search_api_config_service.dart';

/// 搜索API配置编辑弹窗（只有 URL + API Key）
class EditSearchApiConfigCard extends StatefulWidget {
  const EditSearchApiConfigCard({super.key});

  @override
  State<EditSearchApiConfigCard> createState() =>
      _EditSearchApiConfigCardState();
}

class _EditSearchApiConfigCardState extends State<EditSearchApiConfigCard> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final searchApiService = SearchApiConfigService.instance;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadExistingConfig();
  }

  Future<void> _loadExistingConfig() async {
    final config = await searchApiService.getConfig();
    if (config != null) {
      _urlController.text = config.url;
      _apiKeyController.text = config.apiKey;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('搜索API 配置'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API Endpoint URL',
                hintText: 'https://api.tavily.com/search',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '必填' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'tvly-xxxx 或 fc-xxxx',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? '必填' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              await searchApiService.updateConfig(
                url: _urlController.text.trim(),
                apiKey: _apiKeyController.text.trim(),
              );
              if (mounted) {
                Navigator.of(context).pop(true);
              }
            }
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
