# Changelog

All notable changes to this Homebrew tap are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Tap "versions" are **dated snapshots** ([CalVer](https://calver.org/) `YYYY.MM.DD`)
for changelog/provenance only — `brew` always installs from `main`; the
authoritative version of each tool is the `version`/`url` pinned in its formula.

## [2026.06.12]

Bootstrap of tap-level versioning. This snapshot records the formula versions
shipped on `main` as of this date.

### Changed

- `safe-upgrade` 0.2.5 → **0.2.6** — bump `url`/`sha256` to the upstream
  [v0.2.6 release](https://github.com/sharkyger/homebrew-safe-upgrade/releases/tag/v0.2.6).
- `pip-cve-gate` 0.1.0 → **0.2.1** — bump `url`/`sha256` to the upstream PyPI
  sdist (vendored resource block regenerated; dependency tree unchanged).

### Unchanged (recorded for provenance)

- `safe-fetch` **0.3.0** — already current.

### Added

- `CHANGELOG.md` (this file) and a tap-versioning clarifier in `README.md`.

[2026.06.12]: https://github.com/sharkyger/homebrew-tap/releases/tag/2026.06.12
