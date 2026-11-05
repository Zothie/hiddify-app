import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hiddify/core/http_client/dio_http_client.dart';

void main() {
  // Real behaviour under test: the app fetches subscriptions through the
  // active core's proxy port. In VPN mode the core can stall such proxied
  // requests past any timeout (relay-IP routing quirks), while the machine
  // reaches the same host directly in milliseconds. The client must prefer
  // the direct path and only fall back to the proxy when direct cannot
  // answer — a hanging proxy must never break the fetch.
  test('download succeeds via direct despite a hanging proxy port', () async {
    final payload = 'subscription-payload-${DateTime.now().millisecondsSinceEpoch}';
    final server = HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final http = await server;
    http.listen((req) async {
      req.response.headers.contentType = ContentType.text;
      req.response.write(payload);
      await req.response.close();
    });

    // A black-hole proxy: accepts TCP, never answers. This is what the VPN
    // mode core looks like while it is stalling a proxied request.
    final hole = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    hole.listen((sock) {
      // accept and keep silent
    });

    final client = DioHttpClient(
      timeout: const Duration(seconds: 2),
      userAgent: 'test',
      debug: false,
    )..port = hole.port;

    final tmpPath =
        '${Directory.systemTemp.path}/dio-test-${DateTime.now().millisecondsSinceEpoch}.tmp';
    final sw = Stopwatch()..start();
    try {
      await client
          .download('http://127.0.0.1:${http.port}/sub', tmpPath)
          .timeout(const Duration(seconds: 10));
      sw.stop();
      final body = await File(tmpPath).readAsString();
      expect(body, payload);
      // The direct path answers in milliseconds; anything past 8s means the
      // request was parked on the black-hole proxy instead of falling back.
      expect(sw.elapsedMilliseconds, lessThan(8000));
    } finally {
      await http.close(force: true);
      await hole.close();
      if (await File(tmpPath).exists()) await File(tmpPath).delete();
    }
  });
}
