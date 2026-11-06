import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';

/// One-tap "don't tunnel" presets for latency-sensitive gaming traffic.
///
/// Presets are data only; the application points are:
///  - Android: [presetAndroidPackages] are merged into the per-app-proxy
///    exclude list (`Preferences.excludeApps`) by the `PerAppProxyService`
///    watcher, so the Kotlin `VPNService` disallows those packages from the
///    VPN. Only meaningful when per-app mode is [AppProxyMode.exclude]:
///    in include mode the exclude list is not consulted at all.
///  - Desktop: [presetDesktopProcessNames] become sing-box `process_name`
///    route rules (outbound `direct`), built by hiddify-core from the
///    `direct-process-names` HiddifyOptions field. Android ignores them.
///  - [TunnelPresetPortRule] entries document the port set that the core
///    injects when the `direct-game-ports` flag is on (game_servers preset).
///    The core owns the numbers; this file documents them for the UI.
class TunnelPresetPortRule {
  const TunnelPresetPortRule({required this.network, required this.ports});

  /// 'udp' or 'tcp'.
  final String network;

  /// Human-readable port set, e.g. "27000-27100" or "4380".
  final String ports;
}

class TunnelPreset {
  const TunnelPreset({
    required this.id,
    required this.androidPackages,
    required this.desktopProcessNames,
    required this.portRules,
  });

  final String id;

  /// Android package names merged into the exclude list. Empty when the
  /// preset has no Android surface.
  final List<String> androidPackages;

  /// Desktop process names for sing-box `process_name` direct rules.
  /// Empty when the preset is not process-based.
  final List<String> desktopProcessNames;

  /// Port rules mirrored in the core's `direct-game-ports` flag. Empty when
  /// the preset is not port-based.
  final List<TunnelPresetPortRule> portRules;
}

/// Steam remote play / companion apps.
///
/// On Android the Steam mobile app (`com.valvesoftware.android.steam.community`)
/// is the chat/store/auth companion — it is NOT the Steam streaming (SDR) host:
/// Steam Remote Play streaming runs desktop-side. Excluding it keeps Steam
/// companion traffic off the tunnel. `com.valvesoftware.steamlink` (Steam Link)
/// is the actual Android Remote Play client; its video/audio stream is
/// latency-sensitive, so it belongs out of the tunnel too.
/// Desktop: the Remote Play host lives in `steam.exe`, so the desktop client
/// process gets a `process_name` direct rule. `steamwebhelper` (UI/browser)
/// is deliberately NOT excluded: it is not latency-sensitive.
const steamRemotePlayPreset = TunnelPreset(
  id: 'steam_remote_play',
  androidPackages: [
    'com.valvesoftware.android.steam.community',
    'com.valvesoftware.steamlink',
  ],
  desktopProcessNames: ['steam.exe'],
  portRules: [],
);

/// Radmin VPN.
///
/// Radmin VPN is a Windows-only LAN-VPN product: there is no Android app to
/// exclude. On desktop its processes get `process_name` direct rules so the
/// Radmin tunnel traffic never enters the proxy tunnel. Names follow the
/// shipped executables ("RadminVPN.exe" GUI/service host, legacy "radmin.exe",
/// service "RadminVpnService"); exact image names vary slightly by version.
const radminVpnPreset = TunnelPreset(
  id: 'radmin_vpn',
  androidPackages: [],
  desktopProcessNames: ['RadminVPN.exe', 'radmin.exe', 'RadminVpnService'],
  portRules: [],
);

/// Classic game-server port range.
///
/// Port-based, not app-based: any game traffic to these ports leaves the
/// tunnel. Ports follow Valve's documented Steam requirements
/// (help.steampowered.com, "Required Ports for Steam"): UDP 27000-27100
/// (game server traffic), UDP 4380 (P2P/matchmaking) and TCP 27015
/// (Source dedicated server query/RCON). The core injects the same set
/// when the `direct-game-ports` option is enabled.
const gameServersPreset = TunnelPreset(
  id: 'game_servers',
  androidPackages: [],
  desktopProcessNames: [],
  portRules: [
    TunnelPresetPortRule(network: 'udp', ports: '27000-27100'),
    TunnelPresetPortRule(network: 'udp', ports: '4380'),
    TunnelPresetPortRule(network: 'tcp', ports: '27015'),
  ],
);

const tunnelPresets = <TunnelPreset>[steamRemotePlayPreset, radminVpnPreset, gameServersPreset];

/// Presets selected by the persisted toggles.
List<TunnelPreset> activeTunnelPresets({required bool steam, required bool radmin, required bool gamePorts}) {
  return [
    if (steam) steamRemotePlayPreset,
    if (radmin) radminVpnPreset,
    if (gamePorts) gameServersPreset,
  ];
}

/// Android package names to merge into the exclude list.
List<String> presetAndroidPackages(Iterable<TunnelPreset> presets) =>
    presets.expand((p) => p.androidPackages).toSet().toList();

/// Desktop process names for the core's `direct-process-names` option.
List<String> presetDesktopProcessNames(Iterable<TunnelPreset> presets) =>
    presets.expand((p) => p.desktopProcessNames).toSet().toList();

/// Merges preset packages into the current exclude list, keeping existing
/// entries and their order. Idempotent: re-applying the same preset returns
/// an equal list.
List<String> mergePresetPackages({required List<String> excluded, required Iterable<String> presetPackages}) {
  final merged = List<String>.of(excluded);
  final seen = excluded.toSet();
  for (final pkg in presetPackages) {
    if (seen.add(pkg)) merged.add(pkg);
  }
  return merged;
}

/// Removes exactly the preset packages; user selections survive.
List<String> removePresetPackages({required List<String> excluded, required Iterable<String> presetPackages}) {
  final preset = presetPackages.toSet();
  return excluded.where((pkg) => !preset.contains(pkg)).toList();
}

/// Applies the active presets to the per-app exclude list respecting the
/// per-app mode: presets are only meaningful in EXCLUDE mode, where the
/// exclude list decides what bypasses the tunnel. In INCLUDE mode the exclude
/// list is never consulted, so the list is returned unchanged.
List<String> applyPresetsToExcludeList({
  required AppProxyMode mode,
  required List<String> excluded,
  required List<TunnelPreset> activePresets,
}) {
  switch (mode) {
    case AppProxyMode.include:
      return excluded;
    case AppProxyMode.exclude:
      return mergePresetPackages(excluded: excluded, presetPackages: presetAndroidPackages(activePresets));
  }
}
