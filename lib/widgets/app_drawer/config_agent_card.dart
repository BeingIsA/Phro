import 'package:flutter/material.dart';

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

    return AlertDialog(
      title: Text(isEdit ? '编辑 Agent' : '新建 Agent'),
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
                autofocus: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _identityController,
                maxLines: 8,
                minLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Identity（系统提示词） *',
                  hintText: '你是一个专业的...',
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
          child: Text(isEdit ? '保存修改' : '创建'),
        ),
      ],
    );
  }
}
