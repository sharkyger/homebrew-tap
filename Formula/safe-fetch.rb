class SafeFetch < Formula
  include Language::Python::Virtualenv

  desc "Docker-isolated URL fetcher + Layer-2 prompt-injection sanitizer"
  homepage "https://github.com/sharkyger/safe-fetch"
  url "https://github.com/sharkyger/safe-fetch/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "REPLACE_WITH_REAL_TARBALL_SHA256_AT_TAG_TIME"
  license "MIT"
  head "https://github.com/sharkyger/safe-fetch.git", branch: "main"

  depends_on "python@3.12"

  # Resource blocks below are placeholders. After `git tag -s v1.0.0` on
  # safe-fetch and updating the url/sha256 above, run:
  #
  #   brew update-python-resources Formula/safe-fetch.rb
  #
  # to populate these from PyPI. The script ../bin/release-safe-fetch.sh
  # automates the whole sequence.

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/source/b/beautifulsoup4/beautifulsoup4-4.12.3.tar.gz"
    sha256 "74e3d1928edc070d21748185c46e3fb33490f22f52a3addee9aee0f4f7781051"
  end

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/source/l/lxml/lxml-5.3.0.tar.gz"
    sha256 "4e109ca30d1edec1ac60cdbe341905dc3b8f55b16855e03a54aaf59e51ec8c6f"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/source/s/soupsieve/soupsieve-2.6.tar.gz"
    sha256 "e2e68417777af359ec65daac1057404a3c8a5455bb8abc36f1a9866ab1a51abb"
  end

  def install
    virtualenv_install_with_resources
  end

  def caveats
    <<~EOS
      safe-fetch requires Docker for container isolation.

      If Docker isn't installed yet:
        brew install --cask docker
        # then start Docker.app once

      Optional: install the Claude Code prompt-injection-gate hooks:
        safe-fetch --install-claude-hooks

      Full docs: https://github.com/sharkyger/safe-fetch
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/safe-fetch --version")
    # Help / usage path exits non-zero with the USAGE message on stderr;
    # check the install gate works without invoking docker.
    output = shell_output("#{bin}/safe-fetch 2>&1", 2)
    assert_match "safe-fetch", output
  end
end
