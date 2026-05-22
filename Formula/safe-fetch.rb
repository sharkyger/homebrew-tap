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
    url "https://files.pythonhosted.org/packages/b3/ca/824b1195773ce6166d388573fc106ce56d4a805bd7427b624e063596ec58/beautifulsoup4-4.12.3.tar.gz"
    sha256 "74e3d1928edc070d21748185c46e3fb33490f22f52a3addee9aee0f4f7781051"
  end

  resource "lxml" do
    url "https://files.pythonhosted.org/packages/e7/6b/20c3a4b24751377aaa6307eb230b66701024012c29dd374999cc92983269/lxml-5.3.0.tar.gz"
    sha256 "4e109ca30d1edec1ac60cdbe341905dc3b8f55b16855e03a54aaf59e51ec8c6f"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/d7/ce/fbaeed4f9fb8b2daa961f90591662df6a86c1abf25c548329a86920aedfb/soupsieve-2.6.tar.gz"
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
    # Usage path exits non-zero with USAGE on stderr; this exercises the
    # install gate without invoking docker.
    output = shell_output("#{bin}/safe-fetch 2>&1", 2)
    assert_match "safe-fetch", output
  end
end
