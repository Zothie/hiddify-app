import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Minimal preset section for the per-app proxy screen: one switch per
/// "don't tunnel" preset (Steam remote play, Radmin VPN, game server ports).
///
/// Presets only act in EXCLUDE mode: they add packages to the exclude list
/// (Android) and desktop process names to the core config, both of which are
/// consulted only in that mode. In INCLUDE/OFF mode the switches are disabled
/// with an explanation, matching the per-app mode semantics.
class TunnelPresetsSection extends ConsumerWidget {
  const TunnelPresetsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final theme = Theme.of(context);
    final presetsActive = ref.watch(Preferences.perAppProxyMode) == PerAppProxyMode.exclude;
    final presets = t.pages.settings.routing.generalOptions.perAppProxy.presets;

    Widget tile({
      required String title,
      required bool value,
      required ValueChanged<bool>? onChanged,
    }) {
      return SwitchListTile.adaptive(
        dense: true,
        title: Text(title),
        subtitle: presetsActive ? null : Text(presets.includeModeHint),
        value: presetsActive && value,
        onChanged: presetsActive ? onChanged : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(presets.title, style: theme.textTheme.titleMedium),
        ),
        tile(
          title: presets.steam,
          value: ref.watch(Preferences.tunnelPresetSteam),
          onChanged: (v) => ref.read(Preferences.tunnelPresetSteam.notifier).update(v),
        ),
        tile(
          title: presets.radmin,
          value: ref.watch(Preferences.tunnelPresetRadmin),
          onChanged: (v) => ref.read(Preferences.tunnelPresetRadmin.notifier).update(v),
        ),
        tile(
          title: presets.gamePorts,
          value: ref.watch(Preferences.tunnelPresetGamePorts),
          onChanged: (v) => ref.read(Preferences.tunnelPresetGamePorts.notifier).update(v),
        ),
      ],
    );
  }
}
