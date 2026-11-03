import 'dart:async';
import 'dart:io';

import 'package:hiddify/utils/custom_loggers.dart';

/// Keeps the sing-box core log bounded.
///
/// libbox holds box.log open in append mode and grows it without limit while
/// the core runs (a days-long session reached 1.3 GB). The trim runs in place
/// on the SAME inode (RandomAccessFile.truncate + tail rewrite) because
/// replacing the file would leave the core writing to an orphaned inode.
/// Keeps the newest [tailBytes] so the in-app log viewer keeps recent context.
class BoxLogTrimmer with InfraLogger {
  BoxLogTrimmer({
    required this.path,
    this.maxBytes = 100 * 1024 * 1024,
    this.tailBytes = 2 * 1024 * 1024,
    this.period = const Duration(hours: 1),
  });

  final String path;
  final int maxBytes;
  final int tailBytes;
  final Duration period;

  Timer? _timer;
  bool _trimming = false;

  void start() {
    _timer ??= Timer.periodic(period, (_) => trim());
    // immediate check: covers an oversized log inherited from an older build
    trim();
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> trim() async {
    if (_trimming) return;
    _trimming = true;
    try {
      final file = File(path);
      if (!await file.exists()) return;
      final len = await file.length();
      if (len <= maxBytes) return;
      final from = len - tailBytes;
      final raf = await file.open(mode: FileMode.append);
      try {
        await raf.setPosition(from);
        final tail = await raf.read(tailBytes);
        await raf.truncate(0);
        // the fd is O_APPEND, so this write lands at the new EOF (0)
        await raf.writeFrom(tail);
        await raf.flush();
      } finally {
        await raf.close();
      }
      loggy.info("trimmed core log $path: $len -> $tailBytes bytes");
    } catch (e) {
      // a failed trim must never take the core down; next period retries
      loggy.warning("core log trim failed", e);
    } finally {
      _trimming = false;
    }
  }
}
