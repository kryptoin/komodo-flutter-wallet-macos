# Komodo Flutter Wallet

A cross-platform cryptocurrency wallet and DEX client built with **Flutter**, bridging to the Rust-based **Komodo DeFi Framework (KDF / MarketMaker 2)** core for non-custodial key management, UTXO/SmartChain/tendermint/EVM support, and atomic-swap trading.

This repository is a self-contained fork: the Flutter app (`lib/`, package name `web_dex`), the UI/theme packages, and the **entire Komodo SDK monorepo are vendored in-tree** so the project builds without fetching upstream git dependencies.

---

## Repository layout

| Path | Size | What it is |
|---|---|---|
| `lib/` | ~6 MB | The Flutter application (`web_dex`): UI, BLoCs, routing, services |
| `sdk/komodo-defi-sdk/` | ~1 GB | Vendored Komodo SDK monorepo: `komodo_defi_sdk`, `komodo_defi_types`, `komodo_defi_rpc_methods`, `komodo_defi_local_auth`, `komodo_defi_framework` (Dart side), `komodo_cex_market_data`, `komodo_coins`, `dragon_logs`, `komodo_ui`, and more |
| `sdk/komodo-defi-framework/` | ~760 MB | KDF Rust source (MM2). Contains `target/` (~720 MB) — Cargo build artifacts from local `libkdf` compilation |
| `sdk/dart-sdk/` | ~625 MB | Vendored Dart SDK checkout (tooling reference; git-ignored, safe to delete) |
| `packages/` | ~5 MB | First-party packages: `komodo_ui_kit`, `komodo_persistence_layer` |
| `app_theme/` | <1 MB | Theme definitions |
| `macos/`, `web/` | — | Platform runners (macOS and web are the maintained targets) |
| `build/` | ~4 GB | Flutter/Xcode build output — safe to delete, regenerated on every build |
| `docs/` | — | Reserved for future design docs (currently empty) |

> **Why is the folder ~7 GB?** Roughly: `build/` 4.1 GB + `sdk/komodo-defi-framework/target/` 0.7 GB are regenerable build caches; the rest is the vendored SDK/framework sources that `pubspec.yaml` path-dependencies point at. Deleting `build/` is always safe; deleting `target/` forces a long Rust recompile of `libkdf`.

---

## Requirements

| Dependency | Version | Notes |
|---|---|---|
| macOS | 13+ (developed on 26.x, Apple Silicon) | Intel macs untested |
| Xcode | Current stable | Provides clang + macOS SDK; required by `flutter build macos` and CocoaPods |
| Homebrew | current | Package manager bootstrap |
| Flutter | **>= 3.35.3** (tested with 3.47.5 stable) | Dart SDK >= 3.8.1 enforced by `pubspec.yaml` |
| CocoaPods | current | `pod install` for the macOS runner |
| Rust toolchain (rustup/cargo) | stable | Only needed if prebuilt `libkdf` binaries are unavailable and the framework must be compiled locally |
| Apple Developer identity | optional | Only required for distribution signing (see [Signing](#signing--entitlements)); local builds are ad-hoc signed |

The build script installs Flutter and CocoaPods via Homebrew if missing, but **Xcode and Homebrew themselves must be present beforehand**.

---

## Building (macOS, Apple Silicon)

One command:

```bash
./build_macos.sh
```

What it does, step by step:

1. **Environment check** — verifies Homebrew; installs Flutter and CocoaPods via Homebrew if missing; warns if `cargo` is unavailable (only matters for the local Rust compile fallback).
2. **Configuration restore** — if the root `pubspec.yaml` is missing, reconstructs a minimal workspace manifest pointing at the vendored path dependencies.
3. **Dependency resolution** — `flutter pub get`, then `pod install` inside `macos/`.
4. **Compile** — `flutter build macos --release`. During this step the `komodo_wallet_build_transformer` fetches a prebuilt `libkdf` (`mac-arm64`/`universal2`) or compiles it from `sdk/komodo-defi-framework/` if no binary is available.
5. **Ad-hoc signing** — re-signs the bundle in layers (see below), because the KDF install script copies the framework *after* Xcode's signing phase, invalidating the signature.

The finished app lands at:

```
build/macos/Build/Products/Release/Komodo Flutter Wallet.app
```

### Expected build noise

- The build may **report a CodeSign failure at the very end** — this is the known KDF-framework-copied-after-signing issue. The script continues and repairs signatures itself; the artifacts are valid.
- A warning about the `[CP-User] Install kdf executable and/or dylib` build phase missing output declarations is harmless.

### First launch

Gatekeeper treats ad-hoc apps as "unidentified developer" software. First launch: **right-click the app → Open**, or run:

```bash
xattr -dr com.apple.quarantine "build/macos/Build/Products/Release/Komodo Flutter Wallet.app"
```

### Cleaning up disk space

Use `cleanup.sh`, which knows exactly which artifacts are regenerable:

```bash
./cleanup.sh                 # light: build/ + pub caches (~4.7 GB, fast rebuild)
./cleanup.sh --dry-run full  # preview the full clean before committing to it
./cleanup.sh full            # + Pods, prebuilt KDF binaries, Cargo target/, web wasm (~6.9 GB)
```

Everything `full` removes is re-downloaded (or recompiled) by the next
`./build_macos.sh` — but expect a much slower rebuild afterwards. The opt-in
`--dart-sdk` flag also removes the unreferenced 625 MB vendored Dart SDK
(`sdk/dart-sdk/`), which the build does **not** restore. See `./cleanup.sh --help`
for all options.

---

## Signing & entitlements

This is the most subtle part of building this app locally, and the source of several hard-to-diagnose failures. Summary of what we learned empirically on macOS 26:

| Scenario | Result |
|---|---|
| Ad-hoc signed (`codesign --sign -`), **no entitlements** | ✅ App runs. Keychain is **unreachable** (`errSecMissingEntitlement`, `-34018`) |
| Ad-hoc signed **with** `keychain-access-groups` | ❌ Killed at launch — `SIGKILL (Code Signature Invalid)`, "Taskgated Invalid Signature". `keychain-access-groups` is a *restricted* entitlement requiring a real signing identity |
| Ad-hoc signed with non-restricted entitlements (e.g. `com.apple.security.network.client`) | ✅ App runs |
| Real Apple identity + `macos/Runner/Release.entitlements` (sandbox + keychain) | ✅ Full functionality — the distribution configuration |

Because local builds cannot carry keychain entitlements, the wallet's secure-storage layer detects keychain failure at startup and **falls back to `SharedPreferences` for local development only**:

- `SecureRpcPasswordMixin` (SDK bootstrap — RPC password)
- `SecureLocalStorage` (`komodo_defi_local_auth` — wallet metadata)

Both log a `WARNING: secure storage unavailable` message when the fallback engages. Only **non-secret metadata** is stored this way; seeds and keys remain inside KDF's own encrypted database. With a properly signed build the Keychain is used and the fallback is dormant.

For distribution: sign with a real Apple identity together with `macos/Runner/Release.entitlements` (App Sandbox + `keychain-access-groups`). A free Apple ID enrolled in Xcode (Settings → Accounts) provides a development identity sufficient to run with full keychain support.

---

## Architecture overview

```
┌─────────────────────────────┐
│   Flutter app (web_dex)     │  BLoC state management, easy_localization
│   lib/                      │
└──────────────┬──────────────┘
               │ komodo_defi_sdk (Dart)
│   ┌──────────┴───────────┐  │
│   │ komodo_defi_types    │  │  domain models (KdfUser, Asset, PubkeyInfo)
│   │ komodo_defi_rpc_methods │  typed RPC client
│   │ komodo_defi_local_auth  │  auth, secure storage, biometrics
│   │ komodo_cex_market_data  │  price/sparkline repositories
│   └──────────┬───────────┘  │
└──────────────┼──────────────┘
               │ komodo_defi_framework (Dart) — spawns & supervises
┌──────────────▼──────────────┐
│  KDF native core (Rust)     │  libkdf framework, spawned as `kdf` helper
│  localhost RPC :7783        │  JSON-RPC (mmrpc 2.0) + SSE event streaming
│  dbdir: ~/Documents/.kdf    │  encrypted wallet DB (seeds, keys, swap history)
└─────────────────────────────┘
```

Key points:

- **KDF is the trust root.** Seeds, private keys, and wallet data never live in the Dart layer; the app talks to KDF over a localhost RPC bound to `127.0.0.1:7783` (`rpc_local_only: true`) authenticated by a randomly generated RPC password.
- **Wallet types.** HD wallets (BIP39 seed, `m/84'...` derivation, multiple addresses per coin) vs legacy Iguana wallets (single address per coin). The derivation method is chosen at wallet creation and drives both coin activation mode and the pubkey strategy used per asset.
- **Long-running operations are KDF tasks** (`task::account_balance::*`, `task::enable_utxo::*`, …) polled by the SDK. The SDK adds deduplication, retries, and timeouts on top.

### Upstream services & providers

The wallet contacts these external services at runtime:

| Service | Purpose | Used by | Notes |
|---|---|---|---|
| Electrum servers (`electrum*.cipig.net` etc.) | UTXO balance/history/broadcast | KDF core | Configured per-coin in `komodo_coins` asset definitions |
| KMD seed nodes (`mm2seed.shorelinecrypto.com`, …) | P2P orderbook/swap network | KDF core | Atomic swap liquidity |
| Komodo price API | Fiat prices (primary) | `komodo_cex_market_data` | Priority order: Komodo → CoinPaprika → CoinGecko. **Binance is disabled in this fork** (`MarketDataConfig(enableBinance: false)`) |
| CoinPaprika / CoinGecko | Fiat prices, OHLC, sparklines (fallbacks) | `komodo_cex_market_data` | |
| Banxa | Fiat on-ramp (Buy page) | `FiatFormBloc` | Provider availability is coin-dependent |
| Komodo trading-status API | Geo/compliance feature gating | `TradingStatusService` | Compile-time env: `GEO_BLOCK`, `FEEDBACK_API_KEY` |
| NTP / `timeapi.io` / `worldtimeapi.org` | Clock sync (swap safety) | `SystemClockRepository` | Binance time provider removed in this fork |

**Privacy note:** every service above sees your IP address — that is inherent to the network layer and cannot be changed by app configuration. If IP privacy matters to you, route the machine through a trusted VPN or Tor. The geo/compliance check is a one-way HTTPS request to Komodo's API, not a tracker, and is a regulatory feature of the wallet — it is not bypassed in this fork.

### Compile-time environment flags

Passed as `--dart-define`s (wired through the build transformer):

| Flag | Effect |
|---|---|
| `GEO_BLOCK=disabled` | Skips the trading-status geo check; trading features always enabled |
| `FEEDBACK_API_KEY=…` | API key for the trading-status service; if empty (and geo-block active), trading is disabled |

---

## Data & log locations (macOS)

| Path | Contents |
|---|---|
| `~/Documents/.kdf/` | KDF database: per-wallet encrypted seed/coin data, swap history |
| `~/Documents/dragon_logs/` | Application logs (`APP-LOGS_<date>.log`). `SHOUT`/`SEVERE` lines are failures worth grepping |
| `~/Library/Preferences/com.komodo.wallet.plist` | `SharedPreferences` — app settings, and (local-dev builds only) the secure-storage fallback data |

### Debugging tips

- **Query KDF directly** while the app runs (password is in the `kdf` process arguments):

  ```bash
  RPCPASS=$(pgrep -fl "Helpers/kdf" | head -1 | sed -n 's/.*rpc_password":"\([^"]*\)".*/\1/p')
  curl -s -u "user:$RPCPASS" \
    -d '{"userpass":"'$RPCPASS'","method":"get_enabled_coins","params":{}}' \
    http://127.0.0.1:7783
  ```

  Useful methods: `get_enabled_coins`, `my_balance` (legacy/Iguana wallets), `task::account_balance::init|status` (HD wallets), `orderbook`, `my_orders`.

- **Wallet metadata** (wallet type, derivation method, activated coins) lives in the `secure_local_storage_user_<name>` key of the SharedPreferences plist — handy for diagnosing HD/Iguana mismatches, which manifest as `CoinIsActivatedNotWithHDWallet` errors from KDF.

- **Stale wallets from failed registrations:** if a registration fails after KDF accepted it (e.g. the historical keychain bug), the wallet exists in KDF's DB but has incomplete app metadata. Delete it from the wallet picker to avoid type-mismatch confusion.

---

## Known limitations (local development builds)

- **Keychain unavailable** → SharedPreferences fallback (see [Signing](#signing--entitlements)). Distribution builds with a real identity use the Keychain.
- **App Sandbox disabled** in ad-hoc builds (sandbox is also a restricted entitlement); file save/open dialogs work because the plugin's entitlement pre-flight is skipped for unsandboxed local builds.
- **Geo/compliance gating** requires `FEEDBACK_API_KEY`; without it (and with geo-block active) trading features are disabled.
- **Pre-existing test failures:** `komodo_defi_local_auth`'s `kdf_auth_service_delete_wallet_test.dart` fails with a `LateInitializationError` (singleton re-initialization in `KomodoDefiFramework` — test isolation bug, unrelated to wallet code). `komodo_defi_rpc_methods` tests require the Dart test runner and cannot resolve Flutter plugin dependencies under `flutter test`.

---

## Useful commands

```bash
./build_macos.sh                 # full release build + sign
./build_macos.sh --debug         # faster debug iteration build + sign
./build_macos.sh --skip-sign     # build only, skip ad-hoc re-sign
flutter analyze                  # static analysis (uses analysis_options.yaml)
flutter test packages/komodo_ui_kit/test  # example: flutter_test package tests
cd sdk/komodo-defi-sdk/packages/<pkg> && dart test  # pure-Dart test packages
flutter build macos --debug      # debug build (faster iteration; still requires the ad-hoc re-sign step)
```

## Further reading

- `sdk/komodo-defi-sdk/packages/komodo_defi_sdk/` — SDK docs and per-package READMEs
- `sdk/komodo-defi-framework/docs/` — KDF (MM2) internals
- `CHANGELOG.md` — fork history (`kmdclassic` → `kmdflutter`)
