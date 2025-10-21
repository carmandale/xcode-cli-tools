# xcode-cli-tools

Simple, reliable bash wrappers for Xcode builds and iOS/visionOS app debugging with Claude Code.

A lightweight alternative to heavy MCP servers—just bash scripts that wrap Apple's tools and capture output to files.

## Features

- ✅ **Dead Simple**: 3 bash scripts, ~100 lines total
- ✅ **Reliable**: Wraps Apple's battle-tested `xcodebuild` and `simctl`
- ✅ **Token-Efficient**: File-based outputs, grep what you need
- ✅ **No Dependencies**: Uses standard macOS tools (`xcrun`, `simctl`)
- ✅ **Works with Claude Code**: Perfect for AI-assisted development
- ✅ **Portable**: Copy installer to any Xcode project
- ✅ **Timestamped Outputs**: Each build and log capture gets its own file

## What's Included

### Scripts (installed by installer)

| Script | Purpose |
|--------|---------|
| `capture-logs` | Capture app console output to file |
| `stop-logs` | Stop background log capture |
| `xcodebuild` | Wrap xcodebuild, capture output to file |

### Documentation

- `INSTALL-XCODE-SCRIPTS.md` - Installation guide
- `INSTALLER-USAGE.md` - Advanced usage patterns
- `.claude/building-with-xcode.md` - Complete reference (installed by installer)

## Quick Start

### 1. Install

```bash
bash install-xcode-scripts.sh
```

### 2. Build Your App

```bash
./claude/scripts/xcodebuild \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  build \
  -destination 'generic/platform=visionOS Simulator'
```

### 3. Capture App Logs

```bash
# Start capture
./claude/scripts/capture-logs com.yourapp.vision

# Launch your app in Xcode (Cmd+R)
# Do your testing...

# Stop capture
./claude/scripts/stop-logs

# Search results
grep ERROR ./build/logs/logs-*.txt
```

### 4. Find Errors

```bash
grep -i error ./build/xcodebuild/build-*.txt
grep -i crash ./build/logs/logs-*.txt
```

## Philosophy

This project replaces heavyweight MCP servers with **focused, reliable bash wrappers**:

- **File-based**: Outputs saved to timestamped files, not in-memory responses
- **Searchable**: Use grep/head/tail to find what you need
- **Simple**: No TypeScript, no protocols, no complexity
- **Token-Efficient**: Only load the data you need
- **Stable**: Built on Apple's tools, no maintenance required

## Why This Over XcodeBuildMCP?

| Metric | XcodeBuildMCP | xcode-cli-tools |
|--------|---|---|
| Setup | 30+ minutes | 30 seconds |
| Tools | 84+ complex tools | 3 bash scripts |
| Reliability | ❌ Often fails | ✅ Battle-tested tools |
| Token Usage | 💸 Large responses | 💰 File-based grep |
| Dependencies | Node.js, TypeScript | Standard macOS |
| Maintenance | 🔧 Requires debugging | 🔒 No updates needed |
| Learning Curve | 🗻 Steep | 🏔️ Minimal |

## Installation & Usage

See **[INSTALL-XCODE-SCRIPTS.md](INSTALL-XCODE-SCRIPTS.md)** for:
- Installation instructions
- What gets installed
- Quick start examples
- Troubleshooting

See **[INSTALLER-USAGE.md](INSTALLER-USAGE.md)** for:
- Advanced usage patterns
- Team distribution
- CI/CD integration
- FAQ

After installation, read the complete guide:
```bash
cat ./.claude/building-with-xcode.md
```

## Usage Examples

### Build for Simulator

```bash
./claude/scripts/xcodebuild \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  build \
  -destination 'generic/platform=visionOS Simulator'
```

### Build for Device

```bash
./claude/scripts/xcodebuild \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  build \
  -destination generic/platform=visionOS
```

### Run Tests

```bash
./claude/scripts/xcodebuild \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  test \
  -destination 'generic/platform=visionOS Simulator'
```

### Capture Logs with Subsystem Filter

```bash
# Capture logs from your app's subsystem
./claude/scripts/capture-logs com.yourcompany.myapp

# Capture from a specific subsystem
./claude/scripts/capture-logs com.yourcompany.myapp.CoreData

# Capture from a specific simulator
./claude/scripts/capture-logs com.yourapp booted
```

### Search Build Output

```bash
# Find all errors
grep -i error ./build/xcodebuild/build-*.txt

# Find warnings
grep -i warning ./build/xcodebuild/build-*.txt

# Show context (3 lines before/after)
grep -C 3 "error:" ./build/xcodebuild/build-*.txt

# Count occurrences
grep -c "ViewController" ./build/xcodebuild/build-*.txt
```

### Search App Logs

```bash
# Find crashes
grep -i crash ./build/logs/logs-*.txt

# Find specific class logs
grep "MyViewController" ./build/logs/logs-*.txt

# Find with context
grep -C 5 "ERROR" ./build/logs/logs-*.txt

# Real-time search multiple log files
tail -f ./build/logs/logs-*.txt | grep MyPattern
```

## File Organization

```
xcode-cli-tools/
├── install-xcode-scripts.sh          ← Run this
├── INSTALL-XCODE-SCRIPTS.md          ← Read this first
├── INSTALLER-USAGE.md                ← Advanced usage
├── README.md                         ← You are here
│
After running installer:
├── .claude/
│   ├── scripts/
│   │   ├── capture-logs
│   │   ├── stop-logs
│   │   └── xcodebuild
│   └── building-with-xcode.md
│
└── build/
    ├── logs/           ← App console logs
    └── xcodebuild/     ← Build outputs
```

## With Claude Code

These scripts are optimized for [Claude Code](https://claude.com/claude-code) integration:

```
User: "Build the visionOS app"
↓
Claude runs: ./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build
↓
Output saved to: ./build/xcodebuild/build-20251021-143022.txt
↓
User: "Find errors"
↓
Claude runs: grep -i error ./build/xcodebuild/build-*.txt
↓
Claude shows only relevant errors (token efficient!)
```

## Supported Platforms

- iOS (Simulator & Device)
- iPadOS (Simulator & Device)
- visionOS (Simulator & Device)
- watchOS (Simulator & Device)
- tvOS (Simulator & Device)
- macOS (native apps)

## Prerequisites

- macOS 11+
- Xcode 13+
- Standard macOS tools: `xcrun`, `simctl` (included with Xcode)

## Troubleshooting

### Scripts not working after install?

Verify they're executable:
```bash
ls -la ./.claude/scripts/
# Should show -rwxr-xr-x for each script
```

If not:
```bash
chmod +x ./.claude/scripts/*
```

### Log capture fails with "Invalid simulator"?

Check available simulators:
```bash
xcrun simctl list
```

Use correct simulator ID or "booted":
```bash
./claude/scripts/capture-logs com.yourapp.vision booted
```

### Can't find grep results?

Verify files exist:
```bash
ls -la ./build/logs/ ./build/xcodebuild/
```

Check the most recent file:
```bash
ls -t ./build/logs/logs-*.txt | head -1
```

## Contributing

This is a minimal, focused project. Suggested improvements:

1. **Add platform support** - watchOS, tvOS, macOS
2. **Create workflow scripts** - Combine build + test + deploy
3. **Add CI/CD examples** - GitHub Actions, GitLab CI
4. **Improve error messages** - Better diagnostics
5. **Add performance tracking** - Build time analysis

## License

MIT - Use freely in any project

## Based On

Igor Makarov's approach to lightweight Xcode automation:
https://gist.github.com/igor-makarov/e46c7827493016765d6431b6bd1d2394

This implementation adds:
- visionOS support
- Self-contained installer
- Comprehensive documentation
- Claude Code integration
- Easy team distribution

## Support

For issues, questions, or suggestions:

1. Check **[INSTALLER-USAGE.md](INSTALLER-USAGE.md)** FAQ
2. Verify simulator is running: `xcrun simctl list`
3. Test manually: `xcrun simctl spawn booted log stream --predicate "subsystem == 'com.example'"`
4. Check `./.claude/building-with-xcode.md` troubleshooting section

## Quick Reference

```bash
# Install
bash install-xcode-scripts.sh

# Build
./claude/scripts/xcodebuild -workspace X.xcworkspace -scheme Y build

# Capture logs
./claude/scripts/capture-logs com.yourapp
./claude/scripts/stop-logs

# Search
grep -i error ./build/xcodebuild/build-*.txt
grep -i crash ./build/logs/logs-*.txt
```

---

**Built for reliable, token-efficient Xcode development with AI assistants.**
