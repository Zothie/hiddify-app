#!/usr/bin/env python3
"""Attach to the Dart VM Service of the phone app (via adb forward),
pause the main isolate, dump the exact await point, capture Dart stdout/stderr."""
import json, subprocess, sys, time
import websocket

PORT = 42389
WS_PATH = "/dGme3kZw660=/ws"

subprocess.run(["adb", "forward", f"tcp:{PORT}", f"tcp:{PORT}"], capture_output=True)
ws = websocket.create_connection(f"ws://127.0.0.1:{PORT}{WS_PATH}", timeout=20)
_n = [0]

def rpc(method, params=None, timeout=20):
    _n[0] += 1
    i = str(_n[0])
    ws.send(json.dumps({"jsonrpc": "2.0", "id": i, "method": method,
                        "params": params or {}}))
    ws.settimeout(timeout)
    while True:
        r = json.loads(ws.recv())
        if r.get("id") == i:
            if "error" in r:
                return {"error": r["error"]}
            return r.get("result", {})

vm = rpc("getVM")
iso = [i["id"] for i in vm["isolates"] if i["type"] == "@Isolate"][0]
print("isolate:", iso)

# subscribe to Dart stdout/stderr + isolate debug events
for stream in ("Stdout", "Stderr", "Extension", "Isolate", "GC"):
    ws.send(json.dumps({"jsonrpc": "2.0", "id": f"s{stream}",
                        "method": "streamListen", "params": {"streamId": stream}}))

# pause the isolate
rpc("pause", {"isolateId": iso}, timeout=5)

stack = None
deadline = time.time() + 15
while time.time() < deadline and stack is None:
    try:
        r = json.loads(ws.recv())
    except Exception:
        break
    if r.get("event") == "::isolate":
        continue
    kind = r.get("event", "")
    if "PauseInterrupted" in r.get("type", "") or "PauseInterrupted" in kind:
        stack = r
    # capture dart print traffic while paused traffic flows
    if r.get("event") in ("::Stdout", "::Stderr"):
        bytes_b64 = r.get("bytes", "")
        import base64
        print("DART-OUT:", base64.b64decode(bytes_b64).decode("utf-8", "replace")[:400])

if stack is None:
    stack = rpc("getStack", {"isolateId": iso})

frames = stack.get("stack", {}).get("frames", [])
print("== frames while paused:", len(frames))
for f in frames[:20]:
    fn = f.get("function", {}).get("name", "?")
    code = f.get("code", {})
    loc = f.get("location", {})
    print(f"  {fn}  @ script={loc.get('script_id')} pos={loc.get('pos')}")

# messages (async chain) — shows what main() is awaiting
messages = stack.get("stack", {}).get("messages", [])
print("== async messages:", len(messages))
for m in messages[:10]:
    print("  ", m.get("function", {}).get("name", "?"))

rpc("resume", {"isolateId": iso})
print("resumed")
