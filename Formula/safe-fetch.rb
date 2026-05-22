class SafeFetch < Formula
  include Language::Python::Virtualenv

  desc "Docker-isolated URL fetcher + Layer-2 prompt-injection sanitizer"
  homepage "https://github.com/sharkyger/safe-fetch"
  url "https://github.com/sharkyger/safe-fetch/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  license "MIT"
  head "https://github.com/sharkyger/safe-fetch.git", branch: "main"

  depends_on "python@3.12"

  # lxml C extensions link against libxml2/libxslt. macOS ships these
  # in the SDK; on Linux, brew installs the formulas.
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  # Resource pins below are placeholders until the release pipeline
  # runs. Workflow (operator-side):
  #   1. git tag -s v1.0.0 in ~/Projects/public/safe-fetch && git push
  #   2. cd ~/Projects/public/homebrew-tap
  #   3. bin/release-safe-fetch.sh v1.0.0       # fills tarball sha256
  #   4. brew update-python-resources Formula/safe-fetch.rb
  #                                             # refreshes URLs + sha256s
  #   5. git commit -am "safe-fetch v1.0.0" && git push

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/source/b/beautifulsoup4/beautifulsoup4-4.12.3.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/source/l/lxml/lxml-5.3.0.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/source/s/soupsieve/soupsieve-2.6.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
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
    # Usage path exits non-zero with USAGE on stderr; this exercises the
    # install gate without invoking docker.
    output = shell_output("#{bin}/safe-fetch 2>&1", 2)
    assert_match "safe-fetch", output
  end
end
