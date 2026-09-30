# Changelog

All notable changes to this fork are documented here.

## [Unreleased]

### Changed
- The "New" badge no longer appears next to the Buy / Sell menu item
  (still shown for NFT and Trading Bot).

### Fixed
- Swap page / Taker order subtab: the sell-coin and orders dropdowns now
  report *why* they are empty. While the geo/trading status check is still
  running they show a spinner instead of a bare "Nothing found"; when
  trading is unavailable in the user's location they say so
  (new shared `table_states.dart`, also used by the maker coin tables).
- `BestOrdersRequest` ignored its `action` field and always sent `sell`.
- Taker form: best orders refresh every time the order dropdown is opened
  (previously only when it had no data), stale responses are dropped if the
  sell coin changes while a request is in flight, and the loaded list stays
  visible during refresh instead of flashing empty.

### Added
- `TtlCache` (`lib/shared/utils/ttl_cache.dart`): TTL cache with in-flight
  request deduplication; errors and `null` results are never cached.
  Wired into `DexRepository`, which the taker, maker, bridge and
  market-maker-bot forms all share:
  - `best_orders` → 10s TTL (also fixes repeated fetches on dropdown open);
    `waitOrderbookAvailability` bypasses it via `skipCache: true`.
  - max taker/maker volume → 15s, min trading volume → 60s: the four
    independent 10s poll timers now collapse into single RPCs.
  - trade preimage (fee estimate) → 5s, keyed by every request input.
  - `invalidateCaches()` on logout / form reset (`TakerClear`),
    `cacheStats()` for debugging.

### Security
- KDF startup config (wallet name, wallet password, `rpc_password`, optional
  passphrase) is no longer passed on the `kdf` process command line, where
  `ps`/`pgrep -afl`/Activity Monitor exposed it in plaintext. It is now
  written to a mode-`0600` temp file handed over via `MM_CONF_PATH` and
  deleted as soon as the RPC is confirmed up. Spawns with empty argv.
  (`komodo_defi_framework` Dart side; no Rust change — KDF already
  documented `MM_CONF_PATH`.)
- Annotated the dormant third-party RPC forward-proxy constant in
  `KdfOperationsRemote` with a security warning (remains disabled).
- README debugging recipe for retrieving the local RPC password updated to
  `defaults read` (the old `pgrep`-from-argv trick no longer applies).

## [1.0.0+1] — 2026-09-29

### Renamed
- Fork renamed from `kmdclassic wallet` to `kmdflutter wallet` to reflect the
  Flutter implementation (`web_dex` app in `lib/`).

### Added
- `build_macos.sh`: reproducible macOS Apple Silicon build (env checks,
  `flutter pub get`, `pod install`, `flutter build macos`, layered ad-hoc
  re-sign for the KDF framework copy-after-sign issue). Supports
  `--debug/--release/--skip-sign`.
- `cleanup.sh`: `light/full` cleanup with `--dry-run`, `--yes`, `--dart-sdk`,
  `--logs` for regenerable artifacts.
- Pinned hosted dependencies in `pubspec.yaml` (`^x.y.z` from
  `pubspec.lock`); `pubspec.lock` is committed for reproducibility.
- `analysis_options.yaml`: `flutter_lints` + narrowed analyzer excludes.
- `.github/workflows/flutter_analyze.yml`: CI for analyze + formatting.
- `.gitattributes`: binary/linguist rules for vendored SDK and native binaries.

### Changed
- Vendored the Komodo SDK monorepo and KDF Rust source in-tree under `sdk/`
  so the project builds without upstream git fetches.
- Disabled Binance in `MarketDataConfig` and removed the Binance time
  provider; price priority is now Komodo → CoinPaprika → CoinGecko.
- Ad-hoc local builds fall back to `SharedPreferences` when the macOS
  Keychain is unreachable (`-34018`); distribution builds with a real Apple
  identity + `Release.entitlements` use the Keychain.

### Removed
- `docs/Implementation.md` (content merged into `README.md`).
- `sdk/dart-sdk/` is git-ignored (unreferenced 625 MB toolchain copy).

### Known limitations
- Local ad-hoc builds: no Keychain, no App Sandbox; see README Signing.
- `komodo_defi_local_auth` delete-wallet test isolation failure; see README.
- `Mm2Api` → `komodo_defi_sdk` migration still in progress (29 files).
