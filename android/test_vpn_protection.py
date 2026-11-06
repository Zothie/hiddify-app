"""Run the production protection callback with a minimal JVM service fixture."""
import pathlib
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parent
CACHE = pathlib.Path.home() / ".gradle/caches/modules-2/files-2.1"


class VPNProtectionTest(unittest.TestCase):
    def test_callback(self):
        source = (ROOT / "app/src/main/kotlin/com/hiddify/hiddify/bg/VPNService.kt").read_text()
        start = source.index("override fun autoDetectInterfaceControl(fd: Int)")
        opening = source.index("{", start)
        depth = 1
        end = opening + 1
        while depth:
            depth += (source[end] == "{") - (source[end] == "}")
            end += 1
        callback = source[start:end]
        wrapper = (ROOT / "app/src/main/kotlin/com/hiddify/hiddify/bg/PlatformInterfaceWrapper.kt").read_text()
        proxy = (ROOT / "app/src/main/kotlin/com/hiddify/hiddify/bg/ProxyService.kt").read_text()
        capability = "override fun usePlatformAutoDetectInterfaceControl(): Boolean"
        def capability_method(text):
            if capability not in text:
                return ""
            return next(line.strip() for line in text.splitlines() if capability in line)
        default_start = wrapper.index("override fun autoDetectInterfaceControl(fd: Int)")
        default_end = wrapper.index("\n    }", default_start) + len("\n    }")
        default_callback = wrapper[default_start:default_end]
        proxy_callback = ""
        signature = "override fun autoDetectInterfaceControl(fd: Int)"
        if signature in proxy:
            proxy_start = proxy.index(signature)
            proxy_end = proxy.index("\n    }", proxy_start) + len("\n    }")
            proxy_callback = proxy[proxy_start:proxy_end]
        fixture = '''
interface Callback {
    fun autoDetectInterfaceControl(fd: Int)
    fun usePlatformAutoDetectInterfaceControl(): Boolean
}
interface Wrapper : Callback {
    DEFAULT_CAPABILITY
    DEFAULT_CALLBACK
}
class Proxy : Wrapper {
    PROXY_CAPABILITY
    PROXY_CALLBACK
}
class Service : Wrapper {
    VPN_CAPABILITY
    var allowed = true
    var seen = -1
    fun protect(fd: Int): Boolean { seen = fd; return allowed }
    CALLBACK
}
fun main() {
    val proxy = Proxy()
    check(!proxy.usePlatformAutoDetectInterfaceControl()) { "proxy falsely requires VPN protection" }
    proxy.autoDetectInterfaceControl(40)
    val missing = object : Wrapper {}
    check(missing.usePlatformAutoDetectInterfaceControl())
    var missingDenied = false
    try { missing.autoDetectInterfaceControl(41) }
    catch (e: java.io.IOException) { missingDenied = true }
    check(missingDenied) { "default required callback silently succeeded" }
    val service = Service()
    check(service.usePlatformAutoDetectInterfaceControl()) { "VPN must require protection" }
    service.autoDetectInterfaceControl(42)
    check(service.seen == 42)
    service.allowed = false
    var denied = false
    try { service.autoDetectInterfaceControl(43) }
    catch (e: java.io.IOException) { denied = true }
    check(denied) { "protect(false) did not fail closed" }
    check(service.seen == 43)
}
'''.replace("DEFAULT_CAPABILITY", capability_method(wrapper)).replace(
            "DEFAULT_CALLBACK", default_callback).replace(
            "PROXY_CAPABILITY", capability_method(proxy)).replace(
            "PROXY_CALLBACK", proxy_callback).replace(
            "VPN_CAPABILITY", capability_method(source)).replace("CALLBACK", callback)
        jars = []
        for group, artifact, version in [
            ("org.jetbrains.kotlin", "kotlin-compiler-embeddable", "2.1.0"),
            ("org.jetbrains.kotlin", "kotlin-stdlib", "2.1.0"),
            ("org.jetbrains.kotlin", "kotlin-script-runtime", "2.1.0"),
            ("org.jetbrains.kotlin", "kotlin-reflect", "1.6.10"),
            ("org.jetbrains.intellij.deps", "trove4j", "1.0.20200330"),
            ("org.jetbrains", "annotations", "13.0"),
            ("org.jetbrains.kotlinx", "kotlinx-coroutines-core-jvm", "1.6.4"),
        ]:
            jars.extend((CACHE / group / artifact / version).glob("*/*.jar"))
        cp = ":".join(map(str, jars))
        java = "/opt/android-studio/jbr/bin/java"
        with tempfile.TemporaryDirectory(prefix="vpn-protection-") as temp:
            path = pathlib.Path(temp)
            (path / "Callback.kt").write_text(fixture)
            subprocess.run([java, "-cp", cp, "org.jetbrains.kotlin.cli.jvm.K2JVMCompiler",
                            "-no-stdlib", "-no-reflect", "-classpath", cp,
                            "-d", str(path / "out"), str(path / "Callback.kt")], check=True)
            subprocess.run([java, "-cp", str(path / "out") + ":" + cp, "CallbackKt"], check=True)


if __name__ == "__main__":
    unittest.main()
