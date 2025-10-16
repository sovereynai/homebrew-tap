# Homebrew Formula for Sovereyn
# Installs both throne (daemon) and reign (CLI) for distributed AI inference

class Reign < Formula
  desc "Sovereyn - Distributed AI inference network (throne daemon + reign CLI)"
  homepage "https://github.com/sovereynai/throne"
  version "0.5.0-livejobs"
  license "MIT" # reign CLI is MIT, throne daemon is proprietary

  # Throne daemon (with embedded mTLS certificates)
  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.4.0/throne_darwin_arm64.tar.gz"
      sha256 "2ff0a8d9a3ba33be807c56233eea8a433debd5801bf243a90792ce7a1cb62c20"
    else
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.4.0/throne_darwin_amd64.tar.gz"
      sha256 "8540b3b5d3e102ccf17d991702f7f001c63c6a43c9b23d06549401f1e01de409"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.4.0/throne_linux_arm64.tar.gz"
      sha256 "b7dd0f64a4a1a61d741d520dac3fb7a0b83deda836448c8822882a6ced624cd6"
    else
      url "https://github.com/sovereynai/throne-releases/releases/download/v0.4.0/throne_linux_amd64.tar.gz"
      sha256 "520fbd924d8e8c333f988d27db3d87a80d1370786954a6dbc6dd47dfecb150e0"
    end
  end

  # Reign CLI (pre-built binary) - v0.5.0-livejobs with LiveJobs command
  resource "reign" do
    on_macos do
      if Hardware::CPU.arm?
        url "https://github.com/sovereynai/reign/releases/download/v0.5.0-livejobs/reign_darwin_arm64"
        sha256 "16dc5bbad57b70e884afcc7625e3e642428bbfe071a03ada3fc4fe4c2db5c06d"
      else
        url "https://github.com/sovereynai/reign/releases/download/v0.5.0-livejobs/reign_darwin_amd64"
        sha256 "960e9f1efd1bb5480eb357bf5d747d877d09769f1d0d7208631219df75bd2917"
      end
    end

    on_linux do
      if Hardware::CPU.arm?
        url "https://github.com/sovereynai/reign/releases/download/v0.5.0-livejobs/reign_linux_arm64"
        sha256 "ec5c61737b8e6bfeb895e53f643db16326c5dc2608ce4e2ad27e5aae82992034"
      else
        url "https://github.com/sovereynai/reign/releases/download/v0.5.0-livejobs/reign_linux_amd64"
        sha256 "c08c07ce0bcdf53e7b7a7bec435b172442b31066990cac3d7f8c90f1eb3d21a7"
      end
    end
  end

  def install
    # Install throne daemon binary (includes embedded certificates!)
    bin.install "throne"

    # Install reign CLI binary (pre-built, no compilation needed)
    resource("reign").stage do
      bin.install "reign"
    end

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
      "SOVEREYN_DATA_DIR" => var/"sovereyn",
      "SOVEREYN_USE_TRACKER" => "1"
    })
  end

  test do
    # Test throne binary
    assert_predicate bin/"throne", :exist?
    assert_predicate bin/"throne", :executable?

    # Test reign CLI
    assert_predicate bin/"reign", :exist?
    assert_predicate bin/"reign", :executable?
    assert_match "Sovereyn", shell_output("#{bin}/reign --help 2>&1")
  end

  def caveats
    <<~EOS
      🎉 Sovereyn installed successfully!

      Two binaries are now available:
        • throne - The inference daemon
        • reign  - The CLI tool

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      🚀 Quick Start (3 steps):

      1. Install Ollama and pull a model:
         brew install ollama
         ollama serve &
         ollama pull llama3.2:3b

      2. Start throne daemon:
         throne serve

         Or run as a service:
         brew services start reign

      3. Use reign CLI:
         reign chat "Hello, AI!"

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      📋 Useful Commands:

      For AI Developers:
        reign status           # Check network health
        reign models           # List local models
        reign models network   # See all network models
        reign chat "prompt"    # Chat with AI
        reign dev status       # Developer dashboard

      For Node Operators:
        reign node status      # Operator dashboard
        reign jobs             # Live job monitoring
        throne serve           # Run daemon manually

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      ✨ What's New in v0.5.0-livejobs:
        • 🆕 reign jobs - Real-time job monitoring with live progress bars
        • 🆕 reign models network - See ALL models across the network
        • 🆕 reign models locate - Find where specific models are hosted
        • 🆕 Beautiful TUI with real-time updates (Bubble Tea)
        • 🆕 Network-wide model visibility and location tracking
        • ✅ Live status tracking: Running, Queued, Completed, Failed
        • ✅ Different icons for Ollama (🤖) vs ONNX (🔬) models

      📍 Data directory: #{var}/sovereyn
      📝 Logs: #{var}/log/sovereyn/

      🔗 Documentation:
        https://github.com/sovereynai/throne
        https://github.com/sovereynai/reign

      👑 Rule Your AI Destiny!
    EOS
  end
end
