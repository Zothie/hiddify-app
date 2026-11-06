import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/hiddifycore/generated/v2/hcore/hcore.pb.dart';
import 'package:hiddify/hiddifycore/hiddify_core_service_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Thin one-line chip with the hydra adaptive outbound state.
///
/// Given the currently selected outbound tag, polls the core's adaptive
/// state every [pollInterval] while mounted. The chip renders only when the
/// core reports a concrete adaptive state for the tag: an "unknown" answer
/// (the outbound is not a hydra adaptive one), an empty tag and any fetch
/// error all keep the chip hidden — the gRPC answer itself is the gate for
/// whether the selected outbound is adaptive, so no app-side protocol
/// knowledge is needed.
///
/// Shows a localized state label, the active candidate id and the attempt
/// count. Unmapped states fall back to the raw state string.
class AdaptiveStateChip extends ConsumerStatefulWidget {
  const AdaptiveStateChip({
    super.key,
    required this.tag,
    this.fetchState,
    this.pollInterval = const Duration(seconds: 5),
  });

  /// Currently selected outbound tag. Empty hides the chip.
  final String tag;

  /// Overridable fetch seam for tests. Defaults to the real core service.
  final Future<GetAdaptiveStateResponse> Function(String tag)? fetchState;

  final Duration pollInterval;

  @override
  ConsumerState<AdaptiveStateChip> createState() => _AdaptiveStateChipState();
}

class _AdaptiveStateChipState extends ConsumerState<AdaptiveStateChip> {
  Timer? _timer;
  GetAdaptiveStateResponse? _response;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(widget.pollInterval, (_) => _poll());
  }

  @override
  void didUpdateWidget(AdaptiveStateChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tag != widget.tag) {
      _response = null;
      _poll();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    final tag = widget.tag;
    if (tag.isEmpty) return;
    final fetch = widget.fetchState ?? ref.read(hiddifyCoreServiceProvider).adaptiveState;
    try {
      final response = await fetch(tag);
      if (mounted) setState(() => _response = response);
    } catch (_) {
      // Core unreachable or query refused: keep the chip hidden.
      if (mounted) setState(() => _response = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final response = _response;
    final state = response?.state ?? '';
    if (widget.tag.isEmpty || state.isEmpty || state == 'unknown') {
      return const SizedBox.shrink();
    }

    final t = ref.watch(translationsProvider).requireValue;
    final label = switch (state) {
      'connected-verified' => t.pages.proxies.adaptiveState.connectedVerified,
      'connecting' => t.pages.proxies.adaptiveState.connecting,
      'searching' => t.pages.proxies.adaptiveState.searching,
      'backoff' => t.pages.proxies.adaptiveState.backoff,
      'need-update' => t.pages.proxies.adaptiveState.needUpdate,
      'closed' => t.pages.proxies.adaptiveState.closed,
      'offline' => t.pages.proxies.adaptiveState.offline,
      _ => state,
    };
    final text = [
      label,
      if (response!.activeId.isNotEmpty) response.activeId,
      '${response.attempts}',
    ].join(' · ');

    final theme = Theme.of(context);
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: theme.textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
