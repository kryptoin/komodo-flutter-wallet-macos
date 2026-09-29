# Changelog

All notable changes to this fork are documented here.

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
