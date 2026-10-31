# CLAUDE.md — hiddify-app (hydra fork)

Кастомная сборка Hiddify для Android с нативным **hydra-outbound** (собственный
VPN-протокол, репо Zothie/hydra) в ядре sing-box.

## Структура проекта (4 репо)

```
~/src/hiddify-app        — Flutter-приложение
  (интеграция: integration/throughput-strategy; feat/hydra — Kotlin-адаптация)
~/src/hiddify-core       — gomobile-ядро (feat/hydra-core-int: integration base
                           + пины сабмодулей на hydra-ветки)
  ├─ hiddify-sing-box    — форк sing-box (feat/hydra-int: protocol/hydra —
  │                        hydra outbound + splitDialer ClientHello-фрагментатор)
  └─ ray2sing            — URI→sing-box парсер (feat/hydra: схема hydra://)
/media/varingait/Lobotomite/vpns/hydra — Rust-референс протокола (эталон)
```

**Пины (feat/hydra-core-int):** hiddify-sing-box = d0d9d6b0 (feat/hydra-int:
rc.2-base + hydra outbound + фрагментатор), ray2sing = 040d7f6.

## Дизайн hydra-outbound

`protocol/hydra/{crypto.go,tunnel.go,session.go,outbound.go,split.go}` — Go-порт
Rust-протокола (эталон: vpns/hydra/src/proto.rs):

- **handshake**: ws-connect → HELLO `[u32 len][salt16][seal(kdf_hello(pub,salt),
  MAGIC+eph)]` ctr0 → REPLY 53Б → CONFIRM ctr1 "hydra-confirm"; аутентикация
  сервера привязана к статическому pubkey (TLS — чистая маскировка, insecure).
- **кадры**: `[4B len][1B type][id16][payload]`, типы 0 OPEN / 1 DATA / 2 DATA-UP /
  3 OPEN-OK / 4 CLOSE / 5 UDP-DATA / 6 UDP-REPLY / 7 HALF-CLOSE; счётчики с
  направлением, AAD, паддинг-бакеты.
- **splitDialer** (split.go): фрагментация ClientHello на проводе — первая
  TCP-сегмента 8–64 Б (разрез на/внутри SNI), далее ≤96 Б (NoDPI-стиль,
  = Rust frag.rs). crypto/tls пишет весь ClientHello одним Write — сплит на
  уровне обёрнутого конна. Всегда включён для TLS-фронта.
- **опция**: `{"type":"hydra","server":…,"server_port":…,"pubkey":"<b64>",
  "path":"/hydra","tls":{"enabled":true,"insecure":true,…}}`; схема
  `hydra://[pub@]host[:port][/path]?pub=…&tls=1&sni=…` (ray2sing).
- UDP через ListenPacket (udp_connect route-action не поддерживается).

**База:** rc.2 hiddify-sing-box (dd10a212) — upstream main сломан (commit-
маркеры в constant/proxy.go, отсутствующие пакеты service/). Не реbase'ить
на upstream main.

## Требуемые компоненты для сборки

| Компонент | Версия/путь | Примечание |
|---|---|---|
| Flutter | **3.38.5** `~/flutter-3.38.5` | `~/flutter` сломан (cache без dart-sdk) — не использовать |
| Go | **1.25.x** (в PATH) | go.mod требует 1.25 |
| Android SDK | `~/Android/Sdk` | |
| Android NDK | `28.2.13676358` | gomobile требует |
| gomobile | sagernet **v0.1.11** `~/go/bin` | `make lib_install` в hiddify-core |
| JDK | 21 | gradle |

## Порядок сборки APK

```bash
# 1) ядро: aar из hiddify-core (ветка feat/hydra-core-int, сабмодули на пинах)
export ANDROID_HOME=~/Android/Sdk \
       ANDROID_NDK_HOME=~/Android/Sdk/ndk/28.2.13676358 \
       PATH=$HOME/go/bin:$PATH
cd ~/src/hiddify-core && make android
# → bin/hiddify-core.aar (~117MB)

# 2) подложить aar в приложение
cp bin/hiddify-core.aar ~/src/hiddify-app/android/app/libs/hiddify-core.aar

# 3) кодогенерация Dart (build_runner/freezed — без них compileReleaseKotlin
#    упадёт на отсутствующих .g.dart)
cd ~/src/hiddify-app && dart pub get
dart run build_runner build --delete-conflicting-outputs

# 4) APK
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

**Заметки к сборке:**
- `make android` собирает все 4 ABI → aar ~117МБ, apk ~370МБ (fat). Для быстрой
  проверки: `flutter build apk --release --target-platform android-arm64`.
- ТЕГ `with_naive_outbound` в hiddify-core Makefile под android ломает линковку
  (libcronet) — при падении собрать с ним удалённым из TAGS.
- **Не запускать `go mod tidy` без нужды**: тягучие теги sing-tun/sing
  (`v0.8.0-beta.*`) были ПЕРЕТАГГИРОВАНЫ апстримом с ломающим содержимым — пиновать
  по хэшу коммитов (`go get pkg@a23b66f7…`), не по тегам. Аналогично не рефрешить
  go.sum при сломанном графе.
- Подпись: без `android/key.properties` APK падает в debug-signature — ставится
  и обновляется с этой же машины; для proper-релиза сгенерить keystore.

## Установка на телефон

```bash
cp build/app/outputs/flutter-apk/app-release.apk /tmp/hiddify-hydra.apk
adb install -r /tmp/hiddify-hydra.apk
```
MIUI/HyperOS: «Установка через USB» должна быть включена, иначе
`INSTALL_FAILED_USER_RESTRICTED`. Экран разблокировать (install-диалог).

## E2E-тест на телефоне

```bash
python3 ~/src/hiddify-app/hydra_phone_e2e.py
```
Прогоняет: preflight → cold start → onboarding («Начать») → добавление подписки
`hydra-sub` (URL из SUB_URL в шапке скрипта) → выбор профиля → connect →
VPN-диалог → проверка трафика. Артефакты: /tmp/hydra-e2e/.

**Профили подписки** (kvm-hop:/usr/local/bin/generate-vless-sub.sh):
- `yandex-hydra` / `relay2-hydra` — hydra:// на relay-server'ы (TLS 8443/8446,
  geo-split на релеях: RU→direct-RU, foreign→hetzner exit)
- vless/hy2/tuic/juicity — прежние лейны
- socks://127.0.0.1:4300x — PC-локальные лейны (только на десктопе)

vpn-health помечает hydra:// как unverifiable (проверяется только телефоном) —
не выбрасывает при регенерации.

## Грабли (обжитые кровью)

- **libbox API drift**: app-Kotlin написан под libbox конкретного базиса. При
  смене базы sing-box ломаются: `cancelNotification`/`useProcFS` (VPNService,
  ProxyService), `AutoRedirectHandler`/`BridgeSession`/`PlatformUser`/`ShellSession`
  (PlatformInterfaceWrapper) — neutralize, а не искать «правильную» базу.
- **rc.2 + свежий sing = несобираемо**: `service/oomkiller` (memory.
  AvailableSupported), `protocol/tailscale` (tun.ICMPForwarder), registry-строки
  dnstt/masterdns/gooserelay/mieru — удалены из ветки feat/hydra-int. Не
  возвращать без апгрейда синг-пинов по хэшам.
- **`go build ./...` может падать** на пакетах вне gomobile-графа — критичен
  только `make android`/gomobile bind.
- **Flutter-приложение = один canvas для uiautomator**: текстов не видно,
  автоматизация — скриншоты + input tap по координатам (см. e2e-скрипт).
- **adb install**: MIUI требует «Установка через USB», иначе
  `INSTALL_FAILED_USER_RESTRICTED`; экран разблокировать.
- **ВерсионName 4.1.2 dev** на integration-ветке — косметика; appId стандартный
  (app.hiddify.com).
