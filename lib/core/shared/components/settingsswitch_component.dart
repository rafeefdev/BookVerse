import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsSwitch extends ConsumerStatefulWidget {
  final bool settingsItem;
  final ValueChanged<bool> onChanged;

  const SettingsSwitch({
    super.key,
    this.settingsItem = false,
    required this.onChanged,
  });

  @override
  ConsumerState<SettingsSwitch> createState() => _SettingsSwitchState();
}

class _SettingsSwitchState extends ConsumerState<SettingsSwitch> {
  @override
  Widget build(BuildContext context) {
    return Switch(value: widget.settingsItem, onChanged: widget.onChanged);
  }
}
