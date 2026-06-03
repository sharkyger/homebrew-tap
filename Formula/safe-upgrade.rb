class SafeUpgrade < Formula
  desc "Fail-closed CVE gate for brew install/upgrade (NVD, OSV, GitHub Advisory)"
  homepage "https://github.com/sharkyger/homebrew-safe-upgrade"
  url "https://github.com/sharkyger/homebrew-safe-upgrade/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "7c4c5cb0307ec012bdf988322ead19006275499641e863840ed1a5339f54ce62"
  license "MIT"
  head "https://github.com/sharkyger/homebrew-safe-upgrade.git", branch: "main"

  # Bash CLIs backed by Python stdlib-only modules — NOT a virtualenv package.
  # The scripts query OSV.dev / GitHub Advisory / NIST NVD with the standard
  # library only, so the single runtime dependency is a python3 interpreter.
  depends_on "python@3.12"

  def install
    # All six files MUST stay co-located: each brew-safe-* script resolves its
    # Python helpers via dirname "${BASH_SOURCE[0]}" WITHOUT readlink, and the
    # fail-closed guard aborts if bottle_resolver.py / dependency_security_check.py
    # are not siblings. Shipping fewer than all six trips that guard (the drift
    # that bit install.sh, fixed upstream in #46).
    libexec.install "brew-safe-upgrade", "brew-safe-install", "brew-safe-update",
                    "dependency_security_check.py", "bottle_resolver.py", "cask_nvd_map.py"

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
      (`brew safe-update` re-downloads into its install dir from GitHub main and
      is meant for the curl|bash install path, not the brew-managed tree.)

      Full docs: https://github.com/sharkyger/homebrew-safe-upgrade
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
  end
end
