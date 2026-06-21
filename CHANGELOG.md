# Changelog

All notable changes to this Homebrew tap are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Tap "versions" are **dated snapshots** ([CalVer](https://calver.org/) `YYYY.MM.DD`)
for changelog/provenance only — `brew` always installs from `main`; the
authoritative version of each tool is the `version`/`url` pinned in its formula.

## [2026.06.21]

### Changed

- `pip-cve-gate` 0.2.1 → **0.3.0** — bump `url`/`sha256` to the upstream PyPI
  sdist for the [v0.3.0 release](https://github.com/sharkyger/pip-cve-gate/releases/tag/v0.3.0)
  (CVE engine swapped to `osv-scanner`; gate flipped fail-open → fail-closed).

### Added

- `pip-cve-gate` formula now declares **`depends_on "osv-scanner"`** — v0.3.0
  delegates CVE lookup to the external engine, so a `url`/`sha256`-only bump
  would have shipped a broken install (the gate fails closed without it).
- Caveats note the engine dependency and the new
  `PIP_CVE_GATE_OSV_SCANNER_BIN` / `_TIMEOUT` environment variables.

## [2026.06.13]

### Changed

- `safe-upgrade` 0.2.6 → **0.2.7** — bump `url`/`sha256` to the upstream
  [v0.2.7 release](https://github.com/sharkyger/homebrew-safe-upgrade/releases/tag/v0.2.7)
  (ecosystem-aware NVD CPE matching, package-anchored output, CVE-named age
  bypass; closes upstream #72–#75). Caveats corrected: the bundled
  self-updater has fetched pinned, SHA-verified release tags — not `main` —
  since upstream 0.2.5.

### Added

- CI: the `install-from-tag` job now also installs and `brew test`s
  **safe-upgrade** on macOS + Linux — previously only its tap syntax was
  checked, so a non-installing formula could have shipped unnoticed.
- `.gitignore`: local fleet session notes (`/CLAUDE.md`) are now ignored,
  matching the convention in the tool repos.
- README tagline + GitHub repo description reframed for public use (the
  previous "Personal Homebrew tap" wording read as maintainer-only).

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

[2026.06.21]: https://github.com/sharkyger/homebrew-tap/releases/tag/2026.06.21
[2026.06.13]: https://github.com/sharkyger/homebrew-tap/releases/tag/2026.06.13
[2026.06.12]: https://github.com/sharkyger/homebrew-tap/releases/tag/2026.06.12
