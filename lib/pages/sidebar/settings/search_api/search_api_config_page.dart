import 'package:flutter/material.dart';
import 'package:phro/services/search_api_config_service.dart';

class SearchApiConfigPage extends StatefulWidget {
  const SearchApiConfigPage({super.key});

  @override
  State<SearchApiConfigPage> createState() => _SearchApiConfigPageState();
}

class _SearchApiConfigPageState extends State<SearchApiConfigPage> {
  final SearchApiConfigService _service = SearchApiConfigService.instance;

  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    final config = await _service.getConfig();
    setState(() {
      if (config != null) {
        _urlController.text = config.url;
        _apiKeyController.text = config.apiKey;
      } else {
        _urlController.clear();
        _apiKeyController.clear();
      }
    });
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _service.updateConfig(
        url: _urlController.text.trim(),
        apiKey: _apiKeyController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('搜索API 配置已保存')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '搜索API 配置',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '支持 Tavily / Firecrawl',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 24),

            // URL 输入
            TextFormField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: 'API Endpoint URL',
                hintText: 'https://api.tavily.com/search',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'URL 不能为空' : null,
            ),
            const SizedBox(height: 16),

            // API Key 输入
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'API Key',
                hintText: 'tvly-xxxx 或 fc-xxxx',
                border: OutlineInputBorder(),
              ),
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'API Key 不能为空'
                  : null,
            ),

            const SizedBox(height: 32),

            // 保存按钮
            ElevatedButton(
              onPressed: _isLoading ? null : _saveConfig,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('保存配置'),
            ),
          ],
        ),
      ),
    );
  }
}
