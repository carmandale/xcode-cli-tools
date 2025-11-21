# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

xcode-cli-tools is a lightweight alternative to XcodeBuildMCP that provides simple bash wrappers around Apple's Xcode development tools. The project consists of an installer script that sets up three core scripts for building iOS/visionOS apps and capturing console logs. This approach prioritizes simplicity, reliability, and token-efficiency over feature complexity - replacing 84+ complex tools with ~100 lines of battle-tested bash scripts.

The installer creates a `.claude/scripts/` directory with wrapper scripts that capture xcodebuild output and simulator logs to timestamped files, enabling efficient grep-based searching instead of loading entire outputs into memory.

## Essential Commands

### Installation
Install the scripts in any Xcode project directory:
```bash
bash install-xcode-scripts.sh
```

This creates the necessary directory structure and installs three executable scripts:
- `./claude/scripts/xcodebuild` - Xcode build wrapper
- `./claude/scripts/capture-logs` - App log capture
- `./claude/scripts/stop-logs` - Stop log capture

### Building Projects
Build iOS/visionOS apps using the wrapper (captures output to timestamped files):
```bash
# Build for simulator
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build -destination 'generic/platform=visionOS Simulator'

# Build for device
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build -destination generic/platform=visionOS

# Run tests
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp test -destination 'generic/platform=visionOS Simulator'
```

### Log Capture Workflow
Capture app console output during testing:
```bash
# Start log capture (filtering by bundle ID/subsystem)
./claude/scripts/capture-logs com.yourapp.vision

# Launch app in Xcode (Cmd+R) and interact with it

# Stop capture
./claude/scripts/stop-logs
```

### Searching Build Output and Logs
Use grep to efficiently search captured output:
```bash
# Find build errors
grep -i error ./build/xcodebuild/build-*.txt

# Find warnings
grep -i warning ./build/xcodebuild/build-*.txt

# Search app logs
grep -i crash ./build/logs/logs-*.txt
grep "MyViewController" ./build/logs/logs-*.txt

# Show context around matches
grep -C 3 "error" ./build/logs/logs-*.txt
```

## File Structure After Installation

```
./
├── .claude/
│   ├── scripts/
│   │   ├── capture-logs       # Log capture script
│   │   ├── stop-logs         # Stop capture script
│   │   └── xcodebuild        # Build wrapper script
│   └── building-with-xcode.md # Complete usage guide
└── build/
    ├── logs/                 # Timestamped app logs
    └── xcodebuild/          # Timestamped build outputs
```

## Key Principles

- **File-based outputs**: All build and log outputs are saved to timestamped files rather than kept in memory
- **Token-efficient**: Use grep/head/tail to search specific information instead of loading entire outputs
- **Reliable**: Built on Apple's battle-tested tools (xcodebuild, simctl) with minimal abstraction
- **Simple**: No dependencies beyond standard macOS developer tools

## Documentation

After installation, read the comprehensive guide:
```bash
cat ./.claude/building-with-xcode.md
```

Key documentation files:
- `README.md` - Project overview and quick start
- `INSTALL-XCODE-SCRIPTS.md` - Installation details and troubleshooting
- `INSTALLER-USAGE.md` - Advanced usage patterns and team distribution

## Troubleshooting

If scripts aren't executable after installation:
```bash
chmod +x ./.claude/scripts/*
```

If log capture fails with "Invalid simulator":
```bash
xcrun simctl list  # Check available simulators
./claude/scripts/capture-logs com.yourapp.vision booted  # Use 'booted' for active simulator
```