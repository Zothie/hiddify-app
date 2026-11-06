import 'package:fixnum/fixnum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/proxy/overview/adaptive_state_chip.dart';
import 'package:hiddify/hiddifycore/generated/v2/hcore/hcore.pb.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

GetAdaptiveStateResponse _response({String state = '', String activeId = '', int attempts = 0}) {
  return GetAdaptiveStateResponse(state: state, activeId: activeId, attempts: Int64(attempts));
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
}
