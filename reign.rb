# Homebrew Formula for Sovereyn
# Installs both throne (daemon) and reign (CLI) for The Realm network

class Reign < Formula
  desc "Sovereyn - Verifiable distributed intelligence network"
  homepage "https://github.com/sovereynai/throne"
  version "0.2.1"
  license "MIT" # reign CLI is MIT, throne daemon is proprietary

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.0/throne_darwin_arm64.tar.gz"
      sha256 "14c9e1664be1c4cea2f9c55f00e623dc12adbb496fbe4e50c1884938b2d67dae"
    else
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.0/throne_darwin_amd64.tar.gz"
      sha256 "064815721a143226aa727287345a588feb83216c6ef0cceb67baefdbf2e62442"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.0/throne_linux_arm64.tar.gz"
      sha256 "ef7446a1a8040360881928169d763b62325310b4c93f5311e36b5b5ad8eb5423"
    else
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.0/throne_linux_amd64.tar.gz"
      sha256 "3a3e2eb128e996d265a8abd6e58cfe7a4fc50d58259cf0c7d2af90b7198dee5e"
    end
  end

  # Reign CLI as a resource (open source, MIT licensed)
  resource "reign" do
    url "https://github.com/sovereynai/reign/archive/refs/tags/v0.2.1.tar.gz"
    sha256 "4d481e3de7639ce2de1950f3c031758c741ec0dc6c047ace721e2a37ea94250e"
  end

  depends_on "go" => :build  # For building reign from source

  def install
    # Install throne daemon binary
    bin.install "throne"

    # Build and install reign CLI from source
    resource("reign").stage do
      system "go", "build",
             "-ldflags", "-s -w -X main.version=#{version}",
             "-o", buildpath/"reign",
             "./cmd/reign"
    end
    bin.install "reign"

    # Create directories for throne data and logs
    (var/"sovereyn").mkpath
    (var/"log/sovereyn").mkpath
  end

  service do
    run [opt_bin/"throne", "serve"]
    working_dir var/"sovereyn"
    keep_alive successful_exit: false
    log_path var/"log/sovereyn/stdout.log"
    error_log_path var/"log/sovereyn/stderr.log"
    environment_variables({
      "PORT" => "8080",
      "SOVEREYN_DATA_DIR" => var/"sovereyn"
    })
  end

  test do
    # Test throne binary exists and is executable
    assert_predicate bin/"throne", :exist?
    assert_predicate bin/"throne", :executable?

    # Test reign CLI exists and shows help
    assert_match "reign", shell_output("#{bin}/reign --help 2>&1")
  end

  def caveats
    <<~EOS
      👑 Sovereyn has been installed!

      Two binaries are now available:
        • throne - The inference daemon (run in background)
        • reign  - The CLI tool (user-facing commands)

      To start the throne daemon as a service:
        brew services start reign

      Or run manually:
        throne serve

      Quick start with reign CLI:
        reign status         # Check daemon and network health
        reign models         # List available models
        reign chat "Hello!"  # Chat with AI models
        reign dev status     # Developer dashboard
        reign node status    # Node operator dashboard

      Prerequisites:
        • Install Ollama: brew install ollama
        • Pull a model: ollama pull llama3.2:3b
        • Start Ollama: ollama serve

      Data directory: #{var}/sovereyn
      Logs: #{var}/log/sovereyn/

      For more information:
        https://github.com/sovereynai/throne
        https://github.com/sovereynai/reign

      👑 Rule Your AI Destiny!
    EOS
  end
end
