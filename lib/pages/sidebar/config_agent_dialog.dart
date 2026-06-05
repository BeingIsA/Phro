import 'package:flutter/material.dart';
import 'package:phro/pages/sidebar/agent_selector.dart';

class ConfigAgentDialog extends StatefulWidget {
  const ConfigAgentDialog({super.key});

  @override
  State<ConfigAgentDialog> createState() => _ConfigAgentDialogState();
}

class _ConfigAgentDialogState extends State<ConfigAgentDialog> {
  final _nameController = TextEditingController();
  final _identityController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _identityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('新建 Agent'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Agent 名称 *',
                  hintText: '例如：专业写作助手',
                ),
                validator: (value) =>
                    value?.trim().isEmpty == true ? '名称不能为空' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identityController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Identity（系统提示词） *',
                  hintText: '你是一个专业的...',
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    value?.trim().isEmpty == true ? 'Identity不能为空' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
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
          child: const Text('保存'),
        ),
      ],
    );
  }
}
