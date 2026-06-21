import 'package:flutter/material.dart';

class SessionSecondaryControl extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  const SessionSecondaryControl({
    super.key,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 44,
      height: 44,
      child: IconButton.filledTonal(
        onPressed: onPressed,
        icon: Icon(icon, size: 22),
        style: IconButton.styleFrom(
          backgroundColor: scheme.surfaceContainerHighest,
        ),
      ),
    );
  }
}
