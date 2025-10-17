# Homebrew Formula for Reign CLI
# Distributed AI inference network CLI tool

class Reign < Formula
  desc "Reign CLI - Command-line interface for Sovereyn's distributed AI network"
  homepage "https://github.com/sovereynai/reign"
  version "0.5.0-livejobs"
  license "MIT"

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

  def install
    # Install reign CLI binary
    # The downloaded filename uses the exact architecture string from the URL
    if OS.mac?
      if Hardware::CPU.arm?
        bin.install "reign_darwin_arm64" => "reign"
      else
        bin.install "reign_darwin_amd64" => "reign"
      end
    elsif OS.linux?
      if Hardware::CPU.arm?
        bin.install "reign_linux_arm64" => "reign"
      else
        bin.install "reign_linux_amd64" => "reign"
      end
    end
  end

  test do
    assert_predicate bin/"reign", :exist?
    assert_predicate bin/"reign", :executable?
    assert_match "Sovereyn", shell_output("#{bin}/reign --help 2>&1")
  end

  def caveats
    <<~EOS
      🎉 Reign CLI installed successfully!

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      ✨ What's New in v0.5.0-livejobs:
        • 🆕 reign jobs - Real-time job monitoring with live progress bars
        • 🆕 reign models network - See ALL models across the network
        • 🆕 reign models locate - Find where specific models are hosted
        • 🆕 Beautiful TUI with real-time updates (Bubble Tea)
        • 🆕 Network-wide model visibility and location tracking
        • ✅ Live status tracking: Running, Queued, Completed, Failed
        • ✅ Different icons for Ollama (🤖) vs ONNX (🔬) models

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      📋 Quick Commands:

      For AI Developers:
        reign status           # Check network health
        reign models           # List local models
        reign models network   # See all network models
        reign chat "prompt"    # Chat with AI
        reign dev status       # Developer dashboard

      For Node Operators:
        reign node status      # Operator dashboard
        reign jobs             # Live job monitoring (NEW!)

      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

      📝 Note: This formula installs reign CLI only.
      For the throne daemon, install separately:
        brew install throne  # Coming soon

      🔗 Documentation:
        https://github.com/sovereynai/reign

      👑 Rule Your AI Destiny!
    EOS
  end
end
