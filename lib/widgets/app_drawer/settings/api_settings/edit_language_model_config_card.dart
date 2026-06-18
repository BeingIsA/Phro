import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/services/model_config_service.dart';

class EditLanguageModelConfigCard extends StatefulWidget {
  final String? id;

  const EditLanguageModelConfigCard({super.key, this.id});

  @override
  State<EditLanguageModelConfigCard> createState() =>
      _EditLanguageModelConfigCardState();
}

class _EditLanguageModelConfigCardState
    extends State<EditLanguageModelConfigCard> {
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
      _nameController.text = config.configName;
      _urlController.text = config.url;
      _modelController.text = config.modelName;
      _apiKeyController.text = config.apiKey;
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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.configNameLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: l10n.urlLabel,
                hintText: l10n.urlExampleHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _modelController,
              decoration: InputDecoration(
                labelText: l10n.modelNameTitle,
                hintText: l10n.modelNameHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.apiKeyLabel,
                hintText: l10n.apiKeyHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final name = _nameController.text;
                  final url = _urlController.text;
                  final model = _modelController.text;
                  final apiKey = _apiKeyController.text;

                  debugPrint('${l10n.configNameLabel}: $name');
                  debugPrint('URL: $url');
                  debugPrint('${l10n.modelNameTitle}: $model');
                  debugPrint('API Key: $apiKey');
                  modelConfigService.saveConfig(
                    id: widget.id,
                    configName: name,
                    url: url,
                    modelName: model,
                    apiKey: apiKey,
                  );
                  Navigator.of(context).pop(true);
                }
              },
              child: Text(l10n.saveButton),
            ),
          ],
        ),
      ),
    );
  }
}
