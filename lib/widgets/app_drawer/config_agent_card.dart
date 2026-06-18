import 'package:flutter/material.dart';
import 'package:phro/l10n/app_localizations.dart';

class ConfigAgentCard extends StatefulWidget {
  final String? initialName;
  final String? initialIdentity;

  const ConfigAgentCard({super.key, this.initialName, this.initialIdentity});

  @override
  State<ConfigAgentCard> createState() => _ConfigAgentCardState();
}

class _ConfigAgentCardState extends State<ConfigAgentCard> {
  late final TextEditingController _nameController;
  late final TextEditingController _identityController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _identityController = TextEditingController(
      text: widget.initialIdentity ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.initialName != null;
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(isEdit ? l10n.editAgentTitle : l10n.newAgentTitle),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.agentNameLabel,
                  hintText: l10n.agentNameHint,
                ),
                validator: (value) =>
                    value?.trim().isEmpty == true ? l10n.nameNotEmptyError : null,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identityController,
                maxLines: 8,
                minLines: 4,
                decoration: InputDecoration(
                  labelText: l10n.identityLabel,
                  hintText: l10n.identityHint,
                  alignLabelWithHint: true,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text.trim(),
                'identity': _identityController.text.trim(),
              });
            }
          },
          child: Text(isEdit ? l10n.saveChangesButton : l10n.createButton),
        ),
      ],
    );
  }
}

