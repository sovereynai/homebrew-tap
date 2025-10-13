# Sovereyn Homebrew Tap

Official Homebrew tap for Sovereyn - the verifiable distributed intelligence network.

## Installation

```bash
brew tap sovereynai/tap
brew install reign
```

This will install both:
- **throne** - The proprietary inference daemon
- **reign** - The open-source CLI tool (MIT licensed)

## Quick Start

```bash
# Start the throne daemon
brew services start reign

# Or run manually
throne serve

# Use the reign CLI
reign status
reign models
reign chat "Explain quantum computing"
```

## Prerequisites

Sovereyn requires Ollama for LLM models:

```bash
# Install Ollama
brew install ollama

# Pull a model
ollama pull llama3.2:3b

# Start Ollama
ollama serve
```

## Available Formulas

- **reign** - Sovereyn throne daemon + reign CLI (v0.2.0)

## Links

- [Throne Repository](https://github.com/sovereynai/throne) - Proprietary daemon
- [Reign Repository](https://github.com/sovereynai/reign) - Open source CLI
- [Documentation](https://github.com/sovereynai/throne#readme)

## License

- Throne daemon: Proprietary
- Reign CLI: MIT License
- This tap: MIT License

---

**Made with ❤️ by the Sovereyn community**

👑 Rule Your AI Destiny!
