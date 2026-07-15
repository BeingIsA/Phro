import 'package:flutter/material.dart';

class MessageExpansionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Widget> child;
  final Color? titleColor;
  final bool initiallyExpanded;

  const MessageExpansionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.titleColor,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 12.0, right: 12.0, bottom: 4.0),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 8.0,
        ),
        leading: Icon(icon, size: 20, color: colorScheme.primary),
        title: Text(
          title,
          style: theme.textTheme.labelLarge?.copyWith(
            color: titleColor ?? colorScheme.onSurfaceVariant,
          ),
        ),
        collapsedBackgroundColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        children: child,
      ),
    );
  }
}
