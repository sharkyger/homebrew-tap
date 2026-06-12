# sharkyger/homebrew-tap

Security-first developer tools for everyone, one `brew install` away:
fail-closed CVE gates that check every package against NIST NVD, OSV.dev,
and the GitHub Advisory Database **before** it installs, and a sandboxed
fetcher for untrusted web content. If you `brew`, `pip`, or feed web pages
to an AI agent, these tools are for you.

## Formulas

| Formula | What it does |
|---------|--------------|
| [`safe-fetch`](Formula/safe-fetch.rb) | Docker-isolated URL fetcher + Layer-2 prompt-injection sanitizer. Ships the `safe-fetch <url>` CLI plus a `--install-claude-hooks` installer for the [companion hook bundle](https://github.com/sharkyger/claude-code-prompt-injection-gate). |
| [`pip-cve-gate`](Formula/pip-cve-gate.rb) | Pre-install CVE gate for pip. Ships `safe-pip`, which wraps `pip install` and blocks vulnerable or freshly published packages before they install. |
| [`safe-upgrade`](Formula/safe-upgrade.rb) | Fail-closed CVE gate for Homebrew. Ships the `brew safe-install` / `brew safe-upgrade` / `brew safe-update` subcommands, which check every package against NVD, OSV.dev, and GitHub Advisory **before** the install/upgrade proceeds. |

## Install

```bash
brew tap sharkyger/tap
brew install safe-fetch      # or: pip-cve-gate, safe-upgrade
```

After install:

```bash
safe-fetch --version
safe-fetch --install-claude-hooks

safe-pip install flask       # pip-cve-gate

brew safe-install <formula>  # safe-upgrade
brew safe-upgrade
```

> Tap releases are dated snapshots for changelog/provenance only. `brew`
> always installs from `main`; the authoritative version of each tool is the
> `version`/`url` pinned in its formula.

## Why a tap?

`brew install sharkyger/tap/safe-fetch` is the standard way to ship a
brew formula without going through the `homebrew-core` review pipeline.
This tap is the home of the sharkyger security CLIs — `safe-fetch`,
`pip-cve-gate`, and `safe-upgrade` today, with future security tools
alongside as they ship. It is built for public use: every formula is
pinned to a tagged, checksum-verified release, and issues and PRs are
welcome in each tool's upstream repo.

The `safe-upgrade` formula installs the brew-wrapper CLIs
(`brew safe-install` / `brew safe-upgrade` / `brew safe-update`) that gate every
Homebrew install behind a vulnerability-DB check. Their upstream source
and the standalone `curl | bash` installer live at
[sharkyger/homebrew-safe-upgrade](https://github.com/sharkyger/homebrew-safe-upgrade).

## License

Tap content (formulas) is MIT-licensed. Each formula's package itself
carries its own license — see the package source linked from the
`homepage` field.
