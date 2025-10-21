# Install Xcode Build & Log Capture Scripts

This installer sets up lightweight bash wrappers for building and debugging iOS/visionOS apps—a simpler, more reliable alternative to XcodeBuildMCP.

## What Gets Installed

| Component | Location | Purpose |
|-----------|----------|---------|
| `capture-logs` | `./.claude/scripts/capture-logs` | Capture app console output to file |
| `stop-logs` | `./.claude/scripts/stop-logs` | Stop background log capture |
| `xcodebuild` | `./.claude/scripts/xcodebuild` | Wrap xcodebuild, capture output to file |
| Documentation | `./.claude/building-with-xcode.md` | Complete usage guide |
| Log directory | `./build/logs/` | App console logs (timestamped) |
| Build directory | `./build/xcodebuild/` | Build outputs (timestamped) |

## Installation

```bash
bash install-xcode-scripts.sh
```

That's it. The installer will:
1. Create necessary directories
2. Install the three scripts with proper permissions
3. Copy the documentation
4. Print a quick-start guide

## What You'll See

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
```

## Usage

After installation, read the full guide:

```bash
cat ./.claude/building-with-xcode.md
```

### Quick Examples

**Build your app:**
```bash
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build -destination 'generic/platform=visionOS Simulator'
```

**Capture logs while testing:**
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

**Find build errors:**
```bash
grep -i error ./build/xcodebuild/build-*.txt
```

## Why This Approach?

| Metric | XcodeBuildMCP | These Scripts |
|--------|---------------|---------------|
| Complexity | TypeScript MCP server, 84+ tools | 3 bash scripts, ~100 lines |
| Setup | Complex, requires debugging | `bash install-xcode-scripts.sh` |
| Reliability | ❌ Often fails | ✅ Wraps Apple's tools directly |
| Token Usage | 💸 Huge responses | 💰 File-based, grep what you need |
| Maintenance | 🐛 Requires TypeScript expertise | 🔒 Simple bash, stable |
| Learning Curve | 🗻 Steep | 🏔️ Minimal |

## Troubleshooting

### "Permission denied" error
```bash
# Make sure installer is executable
chmod +x install-xcode-scripts.sh
bash install-xcode-scripts.sh
```

### Scripts don't work after install
```bash
# Verify they're executable
ls -la ./.claude/scripts/

# Should show:
# -rwxr-xr-x  capture-logs
# -rwxr-xr-x  stop-logs
# -rwxr-xr-x  xcodebuild
```

### Lost the documentation
```bash
# View the guide anytime:
cat ./.claude/building-with-xcode.md
```

## Reinstalling

The installer is idempotent—you can run it multiple times safely. It will:
- Recreate directories (no error if they exist)
- Overwrite scripts with latest version
- Update documentation

```bash
bash install-xcode-scripts.sh
```

## Uninstalling

If you want to remove everything:

```bash
# Remove scripts
rm -rf ./.claude/scripts/

# Remove output directories
rm -rf ./build/logs/ ./build/xcodebuild/

# Remove documentation
rm ./.claude/building-with-xcode.md

# Remove installer
rm install-xcode-scripts.sh
```

## Support

For issues or questions:
1. Check `./.claude/building-with-xcode.md` troubleshooting section
2. Verify simulator is running: `xcrun simctl list`
3. Test manually: `xcrun simctl spawn booted log stream --predicate "subsystem == 'com.example'"`

## Credits

Based on Igor Makarov's approach:
https://gist.github.com/igor-makarov/e46c7827493016765d6431b6bd1d2394

This implementation adds visionOS support and better documentation for Apple development workflows.
