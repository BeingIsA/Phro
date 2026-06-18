import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';
import 'package:phro/services/search_api_config_service.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.searchApiConfigTitle),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: l10n.apiEndpointUrlLabel,
                hintText: ,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _apiKeyController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: l10n.apiKeyLabel,
                hintText: l10n.searchApiKeyHint,
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? l10n.requiredField
                      : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButtonMsg),
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
          child: Text(l10n.saveButton),
        ),
      ],
    );
  }
}
