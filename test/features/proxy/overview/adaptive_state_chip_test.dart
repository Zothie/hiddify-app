import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/proxy/overview/adaptive_state_chip.dart';
import 'package:hiddify/hiddifycore/generated/v2/hcore/hcore.pb.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GetAdaptiveStateResponse _response({
  String state = '',
  String activeId = '',
  int attempts = 0,
  bool blackout = false,
  String blackoutReason = '',
  int coveragePercent = 0,
  bool dpiGateEnabled = false,
  String dpiGateReason = '',
  Map<String, Int64> perCandidate = const {},
  int candidateCount = 0,
  int swapGeneration = 0,
}) {
  return GetAdaptiveStateResponse(
    state: state,
    activeId: activeId,
    attempts: Int64(attempts),
    blackout: blackout,
    blackoutReason: blackoutReason,
    coveragePercent: coveragePercent,
    dpiGateEnabled: dpiGateEnabled,
    dpiGateReason: dpiGateReason,
    perCandidate: perCandidate.entries,
    candidateCount: candidateCount,
    swapGeneration: Int64(swapGeneration),
  );
}

Future<void> _pumpChip(
  WidgetTester tester,
  Future<GetAdaptiveStateResponse> Function(String tag) fetch,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Sync English translations: no shared preferences needed in tests.
        translationsProvider.overrideWith((ref) => Translations()),
      ],
      child: MaterialApp(
        home: Scaffold(body: AdaptiveStateChip(tag: 'hydra-out', fetchState: fetch)),
      ),
    ),
  );
  // Let the first fetch complete and the chip rebuild.
  await tester.pump();
  await tester.pump();
}

Future<void> _unmount(WidgetTester tester) async {
  // Dispose the chip so its periodic polling timer is cancelled.
  await tester.pumpWidget(const SizedBox());
}

void main() {
  testWidgets('shows localized state, active candidate id and attempts for a known adaptive state', (tester) async {
    await _pumpChip(
      tester,
      (tag) async => _response(state: 'connected-verified', activeId: 'candidate-1', attempts: 3),
    );

    expect(find.textContaining('Connected (verified)'), findsOneWidget);
    expect(find.textContaining('candidate-1'), findsOneWidget);
    expect(find.textContaining('3'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('hides when the core answers unknown (outbound is not a hydra adaptive one)', (tester) async {
    await _pumpChip(tester, (tag) async => _response(state: 'unknown'));

    expect(find.byType(Text), findsNothing);

    await _unmount(tester);
  });

  testWidgets('hides when the state query fails', (tester) async {
    await _pumpChip(tester, (tag) async => throw Exception('core down'));

    expect(find.byType(Text), findsNothing);

    await _unmount(tester);
  });

  testWidgets('renders coverage, blackout reason, per-candidate counts and dpi-gate on', (tester) async {
    await _pumpChip(
      tester,
      (tag) async => _response(
        state: 'connected-verified',
        attempts: 2,
        blackout: true,
        blackoutReason: 'reference probes dead',
        coveragePercent: 85,
        dpiGateEnabled: true,
        perCandidate: {'fi-1': Int64(5), 'de-2': Int64(3)},
      ),
    );

    expect(find.textContaining('cov 85%'), findsOneWidget);
    expect(find.textContaining('blackout: reference probes dead'), findsOneWidget);
    expect(find.textContaining('fi-1:5'), findsOneWidget);
    expect(find.textContaining('de-2:3'), findsOneWidget);
    expect(find.textContaining('dpi-gate on'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('renders dpi-gate off with the gate failure reason', (tester) async {
    await _pumpChip(
      tester,
      (tag) async => _response(
        state: 'connecting',
        dpiGateReason: 'model digest mismatch',
      ),
    );

    expect(find.textContaining('dpi-gate off (model digest mismatch)'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('renders the configs line with set size and swap generation after a hot-swap', (tester) async {
    await _pumpChip(
      tester,
      (tag) async => _response(
        state: 'connected-verified',
        attempts: 1,
        candidateCount: 4,
        swapGeneration: 2,
      ),
    );

    expect(find.textContaining('configs: 4 (gen 2)'), findsOneWidget);

    await _unmount(tester);
  });

  testWidgets('omits the configs line before any hot-swap happened', (tester) async {
    await _pumpChip(
      tester,
      (tag) async => _response(state: 'connected-verified', attempts: 1, candidateCount: 4),
    );

    expect(find.textContaining('configs:'), findsNothing);

    await _unmount(tester);
  });

  testWidgets('omits the diagnostics line when the extra snapshot fields carry nothing', (tester) async {
    await _pumpChip(tester, (tag) async => _response(state: 'connected-verified', attempts: 1));

    expect(find.textContaining('dpi-gate'), findsNothing);
    expect(find.textContaining('cov '), findsNothing);
    expect(find.textContaining('blackout'), findsNothing);
    expect(find.textContaining('configs:'), findsNothing);

    await _unmount(tester);
  });
}
