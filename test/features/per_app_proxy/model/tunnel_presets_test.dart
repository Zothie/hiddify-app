import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/per_app_proxy/model/tunnel_presets.dart';

void main() {
  group('preset data', () {
    test('steam preset excludes the Steam mobile app package on Android', () {
      expect(
        steamRemotePlayPreset.androidPackages,
        contains('com.valvesoftware.android.steam.community'),
      );
    });

    test('steam preset carries the desktop client process name', () {
      expect(steamRemotePlayPreset.desktopProcessNames, contains('steam.exe'));
    });

    test('radmin preset has no Android packages (Windows-only product)', () {
      expect(radminVpnPreset.androidPackages, isEmpty);
    });

    test('radmin preset carries the documented desktop process names', () {
      expect(radminVpnPreset.desktopProcessNames, containsAll(['RadminVPN.exe', 'radmin.exe']));
    });

    test('game_servers preset uses port rules and no packages or processes', () {
      expect(gameServersPreset.androidPackages, isEmpty);
      expect(gameServersPreset.desktopProcessNames, isEmpty);
      expect(gameServersPreset.portRules, hasLength(3));
      final networks = gameServersPreset.portRules.map((r) => r.network).toSet();
      expect(networks, containsAll(['udp', 'tcp']));
    });

    test('activeTunnelPresets returns only the enabled presets', () {
      final active = activeTunnelPresets(steam: true, radmin: false, gamePorts: true);
      expect(active, contains(steamRemotePlayPreset));
      expect(active, contains(gameServersPreset));
      expect(active, isNot(contains(radminVpnPreset)));
    });

    test('presetAndroidPackages unions enabled presets only', () {
      final pkgs = presetAndroidPackages([steamRemotePlayPreset, radminVpnPreset]);
      expect(pkgs, contains('com.valvesoftware.android.steam.community'));
    });

    test('presetDesktopProcessNames unions enabled presets only', () {
      final names = presetDesktopProcessNames([steamRemotePlayPreset, radminVpnPreset]);
      expect(names, containsAll(['steam.exe', 'RadminVPN.exe']));
      expect(presetDesktopProcessNames([steamRemotePlayPreset]), isNot(contains('RadminVPN.exe')));
    });
  });

  group('mergePresetPackages', () {
    test('adds missing preset packages', () {
      final merged = mergePresetPackages(excluded: ['com.a'], presetPackages: ['com.b', 'com.c']);
      expect(merged, containsAllInOrder(['com.a', 'com.b', 'com.c']));
    });

    test('keeps existing user selections', () {
      final merged = mergePresetPackages(excluded: ['com.a', 'com.b'], presetPackages: ['com.b']);
      expect(merged, ['com.a', 'com.b']);
    });

    test('is idempotent when re-applied', () {
      final first = mergePresetPackages(excluded: ['com.a'], presetPackages: ['com.b']);
      final second = mergePresetPackages(excluded: first, presetPackages: ['com.b']);
      expect(second, first);
    });

    test('does not mutate the input list', () {
      final original = ['com.a'];
      mergePresetPackages(excluded: original, presetPackages: ['com.b']);
      expect(original, ['com.a']);
    });
  });

  group('removePresetPackages', () {
    test('removes only the preset packages', () {
      final remaining = removePresetPackages(excluded: ['com.a', 'com.b'], presetPackages: ['com.b']);
      expect(remaining, ['com.a']);
    });

    test('removal is safe when nothing was merged yet', () {
      final remaining = removePresetPackages(excluded: ['com.a'], presetPackages: ['com.b']);
      expect(remaining, ['com.a']);
    });
  });

  group('applyPresetsToExcludeList mode semantics', () {
    test('INCLUDE mode leaves the list untouched (presets are meaningless there)', () {
      final result = applyPresetsToExcludeList(
        mode: AppProxyMode.include,
        excluded: ['com.a'],
        activePresets: [steamRemotePlayPreset],
      );
      expect(result, ['com.a']);
    });

    test('EXCLUDE mode merges preset packages', () {
      final result = applyPresetsToExcludeList(
        mode: AppProxyMode.exclude,
        excluded: ['com.a'],
        activePresets: [steamRemotePlayPreset],
      );
      expect(result, containsAll(['com.a', 'com.valvesoftware.android.steam.community']));
    });

    test('no active presets means no change in any mode', () {
      final result = applyPresetsToExcludeList(mode: AppProxyMode.exclude, excluded: ['com.a'], activePresets: []);
      expect(result, ['com.a']);
    });
  });
}
