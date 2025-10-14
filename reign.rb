# Homebrew Formula for Sovereyn
# Installs both throne (daemon) and reign (CLI) for The Realm network

class Reign < Formula
  desc "Sovereyn - Verifiable distributed intelligence network"
  homepage "https://github.com/sovereynai/throne"
  version "0.2.2"
  license "MIT" # reign CLI is MIT, throne daemon is proprietary

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.2/throne_darwin_arm64.tar.gz"
      sha256 "05cffa4c0ab2447eaa0a588aed0d077d47f954e29b82bbbd65cebbc9de34df09"
    else
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.2/throne_darwin_amd64.tar.gz"
      sha256 "8ada28ebb809a3c57f4ccb41299d4e5190b8758aad6f9a567e07c35d177d0f4a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.2/throne_linux_arm64.tar.gz"
      sha256 "ec8df7672dad98ddf527809d5e5270bc6b669a60b970ee1a5af6176f7ecee92e"
    else
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.2.2/throne_linux_amd64.tar.gz"
      sha256 "4af4ca6e63a3b75d9b7dde648993178d8ed595bc32842dc4b372d84f969ea535"
    end
  end

  # Reign CLI as a resource (open source, MIT licensed)
  resource "reign" do
    url "https://github.com/sovereynai/reign/archive/refs/tags/v0.2.2.tar.gz"
    sha256 "bd885fcfd749c91310f99fff426f8af741b31ed052d984f8d84003ee5cf08dc2"
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
