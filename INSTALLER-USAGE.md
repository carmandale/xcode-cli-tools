# Installer Usage Guide

## What is the Installer?

`install-xcode-scripts.sh` is a self-contained bash script that sets up lightweight Xcode build and log capture tools for your project.

**Key Features:**
- ✅ Self-contained (embeds all scripts inline)
- ✅ Works from any directory
- ✅ Idempotent (safe to run multiple times)
- ✅ No external dependencies
- ✅ Portable (copy to any Xcode project)

## Installation

### In Current Project

```bash
bash install-xcode-scripts.sh
```

### In Another Project

Copy the installer to your project and run it:

```bash
cp install-xcode-scripts.sh /path/to/your/xcode/project/
cd /path/to/your/xcode/project/
bash install-xcode-scripts.sh
```

The installer:
1. Creates `./.claude/scripts/` directory
2. Creates `./build/logs/` and `./build/xcodebuild/` directories
3. Installs three executable scripts
4. Copies complete documentation

## Output

You'll see:
```
🔧 Installing Xcode build & log capture scripts...

📂 Creating directories...
   ✅ Directories created

📝 Creating capture-logs script...
   ✅ capture-logs installed

📝 Creating stop-logs script...
   ✅ stop-logs installed

📝 Creating xcodebuild wrapper script...
   ✅ xcodebuild installed

📝 Creating documentation...
   ✅ building-with-xcode.md created

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Installation Complete!
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📂 Files Created:
   ./.claude/scripts/capture-logs
   ./.claude/scripts/stop-logs
   ./.claude/scripts/xcodebuild
   ./.claude/building-with-xcode.md

📁 Directories Created:
   ./.claude/scripts/
   ./build/logs/
   ./build/xcodebuild/

🚀 Quick Start:
   1. Build your app:
      ./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build
   2. Capture logs while testing:
      ./claude/scripts/capture-logs com.yourapp.vision
      # Launch app in Xcode (Cmd+R)
      ./claude/scripts/stop-logs
   3. Find errors:
      grep -i error ./build/xcodebuild/build-*.txt
      grep -i error ./build/logs/logs-*.txt

📖 Documentation:
   Read: ./.claude/building-with-xcode.md

Happy building! 🎉
```

## What Gets Installed

### Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `./claude/scripts/capture-logs` | Capture app console output | `./claude/scripts/capture-logs com.yourapp.vision` |
| `./claude/scripts/stop-logs` | Stop log capture | `./claude/scripts/stop-logs` |
| `./claude/scripts/xcodebuild` | Wrap xcodebuild, capture output | `./claude/scripts/xcodebuild -workspace X -scheme Y build` |

### Directories

| Directory | Purpose |
|-----------|---------|
| `./.claude/scripts/` | Location of all scripts |
| `./build/logs/` | App console logs (timestamped files) |
| `./build/xcodebuild/` | Build outputs (timestamped files) |

### Documentation

| File | Purpose |
|------|---------|
| `./.claude/building-with-xcode.md` | Complete usage guide (251 lines) |

## After Installation

### Read the Full Guide

```bash
cat ./.claude/building-with-xcode.md
```

### Try a Build

```bash
./claude/scripts/xcodebuild \
  -workspace MyApp.xcworkspace \
  -scheme MyApp \
  build \
  -destination 'generic/platform=visionOS Simulator'
```

### Capture Logs

```bash
# Start capture
./claude/scripts/capture-logs com.yourapp.vision

# Launch your app in Xcode (Cmd+R)
# Do your testing...

# Stop capture
./claude/scripts/stop-logs

# Search the results
grep ERROR ./build/logs/logs-*.txt
```

## Advanced Usage

### Using with Claude Code

The scripts are optimized for Claude Code integration:

```bash
# Ask Claude to build:
# "Build the visionOS app for testing"

# Claude will call:
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build -destination 'generic/platform=visionOS Simulator'

# Ask Claude to find errors:
# "Find build errors"

# Claude will run:
grep -i error ./build/xcodebuild/build-*.txt
```

### Custom Subsystem Filtering

Filter app logs by subsystem to reduce noise:

```bash
# Capture logs only from your app's main subsystem
./claude/scripts/capture-logs com.mycompany.myapp

# Capture logs from a specific subsystem
./claude/scripts/capture-logs com.mycompany.myapp.CoreData

# Capture logs from a simulator by ID
./claude/scripts/capture-logs com.yourapp.vision 9A3A4D5B-1234-5678-90AB-CDEF01234567
```

### Search Patterns

Find specific information in outputs:

```bash
# Find build errors
grep -i error ./build/xcodebuild/build-*.txt

# Find warnings
grep -i warning ./build/xcodebuild/build-*.txt

# Find test failures
grep -i "failed\|error" ./build/xcodebuild/build-*.txt

# Search app logs
grep "MyViewController" ./build/logs/logs-*.txt
grep -i crash ./build/logs/logs-*.txt

# Show context around matches
grep -C 3 error ./build/logs/logs-*.txt
```

## Distributing to Your Team

### Option 1: Include in Repository

Commit the installer to your repository:

```bash
git add install-xcode-scripts.sh INSTALL-XCODE-SCRIPTS.md
git commit -m "add: xcode build & log capture scripts"
git push
```

Team members can then:
```bash
git clone <your-repo>
cd <your-repo>
bash install-xcode-scripts.sh
```

### Option 2: Add to Setup Script

Include the installer in your project's setup:

```bash
#!/bin/bash
# setup.sh

echo "Setting up development environment..."

# Install Xcode scripts
bash install-xcode-scripts.sh

echo "✅ Setup complete! Ready to develop."
```

### Option 3: GitHub Workflow

Add to your CI/CD workflow:

```yaml
name: Setup Environment
on: [pull_request]
jobs:
  setup:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - run: bash install-xcode-scripts.sh
```

## Troubleshooting

### "Permission denied" Error

```bash
# Make sure the installer is executable
chmod +x install-xcode-scripts.sh

# Then run it
bash install-xcode-scripts.sh
```

### Scripts Don't Work After Install

Verify the scripts are executable:

```bash
ls -la ./.claude/scripts/
# Should show -rwxr-xr-x for each script
```

If not executable:

```bash
chmod +x ./.claude/scripts/*
```

### Lost Documentation

Reinstall to get the documentation back:

```bash
bash install-xcode-scripts.sh
```

All output files will be recreated (safe to run multiple times).

## Updating Scripts

If you update the installer, just run it again:

```bash
bash install-xcode-scripts.sh
```

This will:
- Update all scripts to latest versions
- Refresh the documentation
- Create any missing directories
- Not affect your existing output files

## Uninstalling

To remove everything:

```bash
# Remove scripts
rm -rf ./.claude/scripts/

# Remove output directories
rm -rf ./build/logs/ ./build/xcodebuild/

# Remove documentation
rm ./.claude/building-with-xcode.md

# Remove installer
rm install-xcode-scripts.sh INSTALL-XCODE-SCRIPTS.md
```

## Why Use This Instead of XcodeBuildMCP?

| Feature | Installer Scripts | XcodeBuildMCP |
|---------|------------------|---------------|
| **Setup** | `bash install-xcode-scripts.sh` | Complex MCP configuration |
| **Complexity** | 3 bash scripts, ~100 lines | 84+ tools, TypeScript server |
| **Reliability** | Wraps Apple's tools directly | Heavy abstraction layers |
| **Token Usage** | File-based, efficient grep | Large response objects |
| **Maintenance** | Stable, no updates needed | Requires ongoing debugging |
| **Learning Curve** | Minimal | Steep (MCP protocol) |

## Questions?

1. **How do I use the scripts?** → Read `./.claude/building-with-xcode.md`
2. **Scripts not working?** → Check [Troubleshooting](#troubleshooting) above
3. **Need a feature?** → Extend the scripts (they're simple bash)
4. **Share with team?** → Copy `install-xcode-scripts.sh` to your repo

## Credits

Based on Igor Makarov's approach:
https://gist.github.com/igor-makarov/e46c7827493016765d6431b6bd1d2394

This implementation adds visionOS support, better documentation, and makes it easy to install across projects.
