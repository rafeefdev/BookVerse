
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsSwitch extends ConsumerStatefulWidget {
  bool settingsItem;
  ValueChanged<bool> onChanged;

  SettingsSwitch({
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
    return Switch(
      value: widget.settingsItem,
      onChanged: widget.onChanged
    );
  }
}
