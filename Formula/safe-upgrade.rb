class SafeUpgrade < Formula
  desc "Fail-closed CVE gate for brew install/upgrade (NVD, OSV, GitHub Advisory)"
  homepage "https://github.com/sharkyger/homebrew-safe-upgrade"
  url "https://github.com/sharkyger/homebrew-safe-upgrade/archive/refs/tags/v0.2.7.tar.gz"
  sha256 "198b3792eda958c073678db455c1e83a5ebb7adf7e27e998fa69c3dd535fa62d"
  license "MIT"
  head "https://github.com/sharkyger/homebrew-safe-upgrade.git", branch: "main"

  # Bash CLIs backed by Python stdlib-only modules — NOT a virtualenv package.
  # The scripts query OSV.dev / GitHub Advisory / NIST NVD with the standard
  # library only, so the single runtime dependency is a python3 interpreter.
  depends_on "python@3.12"

  def install
    # All runtime files MUST stay co-located: each brew-safe-* script resolves its
    # Python helpers relative to its own (symlink-resolved) directory, and the
    # fail-closed guard aborts if bottle_resolver.py / dependency_security_check.py
    # are not siblings. Shipping fewer trips that guard (the drift that bit
    # install.sh, fixed upstream in #46). VERSION feeds `--version` self-diagnosis.
    libexec.install "brew-safe-upgrade", "brew-safe-install", "brew-safe-update",
                    "dependency_security_check.py", "bottle_resolver.py", "cask_nvd_map.py",
                    "VERSION"

    # Expose the brew-safe-* scripts as `brew safe-upgrade` / `safe-install` /
    # `safe-update` external subcommands. A plain bin symlink would make
    # BASH_SOURCE resolve to bin/ (no readlink) and break helper lookup, so use
    # write_env_script: it execs the real libexec copy, keeping BASH_SOURCE in
    # libexec, and prepends python@3.12's unversioned bin so `python3` resolves.
    python_bin = Formula["python@3.12"].opt_libexec/"bin"
    %w[brew-safe-upgrade brew-safe-install brew-safe-update].each do |cmd|
      (bin/cmd).write_env_script libexec/cmd, PATH: "#{python_bin}:$PATH"
    end
  end

  def caveats
    <<~EOS
      Installed three Homebrew external subcommands:
        brew safe-install <formula>   # CVE-gate a new install
        brew safe-upgrade             # CVE-gate `brew upgrade`
        brew safe-update              # refresh the tools themselves

      SHA verification + a 3-day freshness hold are on by default; opt out per
      run with --no-verify-sha / --min-age 0.

      Update via Homebrew, not the bundled self-updater:
        brew update && brew upgrade safe-upgrade
      (`brew safe-update` fetches the latest release tag, SHA-verified, into a
      script install's bin — it is for the curl|bash path, not this brew tree.)

      Full docs: https://github.com/sharkyger/homebrew-safe-upgrade

      💚 Sponsor: https://github.com/sponsors/sharkyger
    EOS
  end

  test do
    # The Python helpers ship alongside the scripts (the parity the upstream
    # fail-closed guard depends on).
    assert_path_exists libexec/"bottle_resolver.py"
    assert_path_exists libexec/"cask_nvd_map.py"
    assert_path_exists libexec/"dependency_security_check.py"

    # Fail-closed guard: with the bottle-SHA resolver pointed at a missing path,
    # the command must abort with exit 2 BEFORE touching the network — proving
    # the integrity check never silently no-ops.
    output = shell_output(
      "BREW_SAFE_BOTTLE_RESOLVER=/nonexistent #{bin}/brew-safe-upgrade 2>&1", 2
    )
    assert_match "bottle SHA resolver not found", output

    # Real self-diagnosis, NO override: proves VERSION ships and the helpers
    # resolve in the actual formula/libexec layout (the script route that an
    # earlier override-based test couldn't see).
    version_out = shell_output("#{bin}/brew-safe-upgrade --version")
    assert_match version.to_s, version_out
    assert_match "helpers: all present", version_out
  end
end
