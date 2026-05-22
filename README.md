# sharkyger/homebrew-tap

Personal Homebrew tap for security tooling.

## Formulas

| Formula | What it does |
|---------|--------------|
| [`safe-fetch`](Formula/safe-fetch.rb) | Docker-isolated URL fetcher + Layer-2 prompt-injection sanitizer. Ships the `safe-fetch <url>` CLI plus a `--install-claude-hooks` installer for the [companion hook bundle](https://github.com/sharkyger/claude-code-prompt-injection-gate). |

## Install

```bash
brew tap sharkyger/tap
brew install safe-fetch
```

After install:

```bash
safe-fetch --version
safe-fetch --install-claude-hooks
```

## Why a tap?

`brew install sharkyger/tap/safe-fetch` is the standard way to ship a
brew formula without going through the `homebrew-core` review pipeline.
This tap is the umbrella for sharky's security CLIs (`safe-fetch` today;
future security tools alongside as they ship).

For the brew-wrapper CLIs (`safe-install`, `safe-upgrade`,
`safe-update`) that gate every Homebrew install behind a vulnerability
DB check, see [sharkyger/homebrew-safe-upgrade](https://github.com/sharkyger/homebrew-safe-upgrade)
(a separate per-tool tap, kept independent for clarity).

## License

Tap content (formulas) is MIT-licensed. Each formula's package itself
carries its own license — see the package source linked from the
`homepage` field.
