class SafeFetch < Formula
  include Language::Python::Virtualenv

  desc "Docker-isolated URL fetcher + Layer-2 prompt-injection sanitizer"
  homepage "https://github.com/sharkyger/safe-fetch"
  url "https://github.com/sharkyger/safe-fetch/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "90be3927d17fbf294bd67f86034d090fc7ca5e680e91a03d681b1b8372df6c1e"
  license "MIT"
  head "https://github.com/sharkyger/safe-fetch.git", branch: "main"

  depends_on "python@3.12"

  # libxml2 / libxslt are linked into the lxml wheel binaries below, so
  # the host system copies are not strictly required at runtime — but
  # keeping the dependency declared is belt-and-braces for users who
  # install the formula with `--build-from-source` from a future tag
  # that switches back to sdist resources.
  uses_from_macos "libxml2"
  uses_from_macos "libxslt"

  resource "beautifulsoup4" do
    url "https://files.pythonhosted.org/packages/c3/b0/1c6a16426d389813b48d95e26898aff79abbde42ad353958ad95cc8c9b21/beautifulsoup4-4.14.3.tar.gz"
    sha256 "6292b1c5186d356bba669ef9f7f051757099565ad9ada5dd630bd9de5fa7fb86"
  end

  resource "soupsieve" do
    url "https://files.pythonhosted.org/packages/47/2c/0a5f6f8ee0d5589e48c7640213ed5175d52cf540a06725b628cc1a45d6ce/soupsieve-2.8.4.tar.gz"
    sha256 "e121fd02e975c695e4e9e8774a5ee35d74714b59307868dcc5319ad2d9e3328e"
  end

  resource "typing-extensions" do
    url "https://files.pythonhosted.org/packages/72/94/1a15dd82efb362ac84269196e94cf00f187f7ed21c242792a923cdb1c61f/typing_extensions-4.15.0.tar.gz"
    sha256 "0cea48d173cc12fa28ecabc3b837ea3cf6f38c6d1136f85cbaaf598984861466"
  end

  # lxml is installed from a pre-built wheel rather than the sdist.
  # Reasons:
  #   - lxml 5.x sdists segfault under modern Python 3.12 + Cython 3.2.5
  #     + setuptools 82+ during get_requires_for_build_wheel.
  #   - lxml 6.x sdists need Cython at build time, but brew's per-resource
  #     pip-install flow uses build-isolation and cannot fetch Cython
  #     into the build sandbox.
  #   - lxml ships well-maintained manylinux + macOS universal2 wheels
  #     for Python 3.12 across both arches, so the wheel install is
  #     reliable, fast, and CVE-clean (lxml 6.1.1 closes PYSEC-2026-87).
  # The on_macos / on_linux + on_arm / on_intel split picks the right
  # wheel for the build host. v0.1.3 follow-up: also handle musllinux
  # if Linuxbrew on Alpine becomes a supported target.
  resource "lxml" do
    on_macos do
      url "https://files.pythonhosted.org/packages/6a/6e/c4add832b6fc1e887125b96f880d7b9b70aae5248718e046b1704bcac4b9/lxml-6.1.1-cp312-cp312-macosx_10_13_universal2.whl"
      sha256 "104c09bda8d2a562824c0e319d0768ce26a779b7601e0931d33b09b53c392ef7"
    end
    on_linux do
      on_arm do
        url "https://files.pythonhosted.org/packages/29/91/317b332636bfc7bddcff828d41b3307f50043f4b237e40849c333d80fa1a/lxml-6.1.1-cp312-cp312-manylinux_2_26_aarch64.manylinux_2_28_aarch64.whl"
        sha256 "96f2ec43df44b1f76249ee0a615334f9b5b060e1c8bd90e706dad2d14d02f383"
      end
      on_intel do
        url "https://files.pythonhosted.org/packages/08/f6/af32e23e563971ffb0fb86be52bc5be5c2c118858ffc119bf6a9039b173d/lxml-6.1.1-cp312-cp312-manylinux_2_26_x86_64.manylinux_2_28_x86_64.whl"
        sha256 "ebe6af670449830d6d9b752c256a983291c766a1365ba5d5460048f9e33a7818"
      end
    end
  end

  def install
    venv = virtualenv_create(libexec, "python3.12")
    venv.pip_install resource("typing-extensions")
    venv.pip_install resource("soupsieve")
    venv.pip_install resource("beautifulsoup4")
    # The lxml resource is a .whl, not an sdist. brew's default
    # `pip_install resource(...)` stages it by extracting the wheel
    # contents into a directory, but pip needs the wheel FILE to
    # install. brew's cached download filename is hash-prefixed
    # (`<sha256>--<original-name>.whl`), which breaks pip's wheel-
    # filename parser. Copy to a clean name in buildpath, then install.
    # brew's resource cache uses a hash-prefixed filename like
    # `<sha256>--lxml-6.1.1-...whl`, which breaks pip's wheel-filename
    # parser. Copy to a clean PEP-427-compliant name in buildpath so
    # pip recognizes it as a wheel.
    wheel_arch_tag = if OS.mac?
      "macosx_10_13_universal2"
    elsif Hardware::CPU.arm?
      "manylinux_2_26_aarch64.manylinux_2_28_aarch64"
    else
      "manylinux_2_26_x86_64.manylinux_2_28_x86_64"
    end
    wheel_name = "lxml-6.1.1-cp312-cp312-#{wheel_arch_tag}.whl"
    cp resource("lxml").cached_download, buildpath/wheel_name
    # The venv is created --without-pip (brew default), so there's no
    # pip binary in libexec/bin. Invoke pip via the system Python's
    # pip module, targeting the venv's python via --python.
    python = Formula["python@3.12"].opt_bin/"python3.12"
    system python, "-m", "pip", "--python=#{libexec}/bin/python",
           "install", "--no-deps", buildpath/wheel_name.to_s
    venv.pip_install_and_link buildpath
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

      💚 Sponsor: https://github.com/sponsors/sharkyger
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
