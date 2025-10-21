#!/bin/bash
# Installer for lightweight Xcode build & log capture scripts
# Based on Igor Makarov's approach: https://gist.github.com/igor-makarov/e46c7827493016765d6431b6bd1d2394
#
# Usage: bash install-xcode-scripts.sh
# This script will:
# - Create .claude/scripts/ directory
# - Create ./build/logs/ and ./build/xcodebuild/ directories
# - Install capture-logs, stop-logs, and xcodebuild scripts
# - Copy building-with-xcode.md documentation
# - Make all scripts executable

set -e

echo "🔧 Installing Xcode build & log capture scripts..."
echo ""

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get script directory (works from anywhere)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📂 Creating directories..."
mkdir -p "${SCRIPT_DIR}/.claude/scripts"
mkdir -p "${SCRIPT_DIR}/build/logs"
mkdir -p "${SCRIPT_DIR}/build/xcodebuild"
echo "   ✅ Directories created"

echo ""
echo "📝 Creating capture-logs script..."
cat > "${SCRIPT_DIR}/.claude/scripts/capture-logs" << 'CAPTURE_LOGS_SCRIPT'
#!/bin/bash
# Captures visionOS/iOS simulator logs to timestamped file
# Usage: ./claude/scripts/capture-logs <subsystem-or-bundle-id> [simulator-id]
# Example: ./claude/scripts/capture-logs com.yourapp.vision
# Example: ./claude/scripts/capture-logs com.yourapp.vision booted

set -e

if [ $# -eq 0 ]; then
  echo "❌ Usage: ./claude/scripts/capture-logs <subsystem-or-bundle-id> [simulator-id]"
  echo "   Example: ./claude/scripts/capture-logs com.yourapp.vision"
  echo "   Example: ./claude/scripts/capture-logs com.yourapp.vision booted"
  exit 1
fi

SUBSYSTEM=$1
SIM_ID=${2:-booted}
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT="./build/logs/logs-${TIMESTAMP}.txt"

# Ensure output directory exists
mkdir -p ./build/logs

echo "📝 Starting log capture..."
echo "   Subsystem: $SUBSYSTEM"
echo "   Simulator: $SIM_ID"
echo "   Output: $OUTPUT"
echo ""

# Start capturing logs filtered by subsystem in background
xcrun simctl spawn "$SIM_ID" log stream --predicate "subsystem == '${SUBSYSTEM}'" > "$OUTPUT" 2>&1 &
PID=$!

# Store the PID so we can stop it later
echo "$PID" > ./build/logs/.last-capture-pid

echo "✅ Log capture started"
echo "🔢 Process ID: $PID"
echo "🛑 To stop capturing, run: ./claude/scripts/stop-logs"
echo "📂 Logs will be saved to: $OUTPUT"
CAPTURE_LOGS_SCRIPT

chmod +x "${SCRIPT_DIR}/.claude/scripts/capture-logs"
echo "   ✅ capture-logs installed"

echo ""
echo "📝 Creating stop-logs script..."
cat > "${SCRIPT_DIR}/.claude/scripts/stop-logs" << 'STOP_LOGS_SCRIPT'
#!/bin/bash
# Stops the active log capture process
# Usage: ./claude/scripts/stop-logs

PID_FILE="./build/logs/.last-capture-pid"

if [ ! -f "$PID_FILE" ]; then
  echo "❌ No active log capture found"
  exit 1
fi

PID=$(cat "$PID_FILE")

if ps -p "$PID" > /dev/null 2>&1; then
  kill "$PID"
  rm "$PID_FILE"
  echo "✅ Stopped log capture (PID $PID)"
else
  echo "⚠️  Process $PID is not running"
  rm "$PID_FILE"
  exit 1
fi
STOP_LOGS_SCRIPT

chmod +x "${SCRIPT_DIR}/.claude/scripts/stop-logs"
echo "   ✅ stop-logs installed"

echo ""
echo "📝 Creating xcodebuild wrapper script..."
cat > "${SCRIPT_DIR}/.claude/scripts/xcodebuild" << 'XCODEBUILD_SCRIPT'
#!/bin/bash
# Wrapper around xcodebuild that captures output to timestamped files
# This follows Igor Makarov's approach: https://gist.github.com/igor-makarov/e46c7827493016765d6431b6bd1d2394
#
# Usage: ./claude/scripts/xcodebuild <standard xcodebuild args>
# Examples:
#   ./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build
#   ./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp test -destination 'generic/platform=visionOS'

set -e

TIMESTAMP=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="./build/xcodebuild"
OUTPUT_FILE="$OUTPUT_DIR/build-${TIMESTAMP}.txt"

# Ensure output directory exists
mkdir -p "$OUTPUT_DIR"

echo "🔨 Running xcodebuild..."
echo "📝 Output will be saved to: $OUTPUT_FILE"
echo ""

# Run xcodebuild and capture output
if xcodebuild "$@" > "$OUTPUT_FILE" 2>&1; then
  EXIT_CODE=0
else
  EXIT_CODE=$?
fi

# Get file size
FILE_SIZE=$(du -h "$OUTPUT_FILE" | cut -f1)

echo ""
echo "✅ xcodebuild completed"
echo "📊 Exit code: $EXIT_CODE"
echo "📦 Output size: $FILE_SIZE"
echo "📂 Output file: $OUTPUT_FILE"
echo ""
echo "💡 Tip: Use grep to search the output, e.g.:"
echo "   grep -i error '$OUTPUT_FILE'"
echo "   grep -i warning '$OUTPUT_FILE'"

exit "$EXIT_CODE"
XCODEBUILD_SCRIPT

chmod +x "${SCRIPT_DIR}/.claude/scripts/xcodebuild"
echo "   ✅ xcodebuild installed"

echo ""
echo "📝 Creating documentation..."
cat > "${SCRIPT_DIR}/.claude/building-with-xcode.md" << 'DOCUMENTATION'
# Building with Xcode - Claude Instructions

This document explains how to use the lightweight build and log capture wrapper scripts instead of the heavy XcodeBuildMCP server.

## Philosophy

This approach replaces XcodeBuildMCP's 84+ tools with simple bash wrappers that:
- ✅ Just work reliably
- ✅ Capture output to files (token-efficient)
- ✅ Follow Igor Makarov's proven pattern
- ✅ Let you search/grep results instead of loading everything

## Build Wrapper: `./claude/scripts/xcodebuild`

### Purpose
Wraps standard `xcodebuild` commands and captures output to timestamped files.

### Usage
```bash
./claude/scripts/xcodebuild -workspace XXX.xcworkspace -scheme YYY <action> [options]
```

### Examples

**Build for visionOS Simulator:**
```bash
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build -destination 'generic/platform=visionOS Simulator'
```

**Run unit tests:**
```bash
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp test -destination 'generic/platform=visionOS Simulator'
```

**Build for device:**
```bash
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build -destination generic/platform=visionOS
```

**Archive for distribution:**
```bash
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp archive -archivePath ./build/MyApp.xcarchive
```

### Output
- ✅ Builds to: `./build/xcodebuild/build-YYYYMMDD-HHMMSS.txt`
- ✅ Reports: Exit code, file size
- ✅ Searchable via grep

### Important Notes
- ❌ **NEVER use `-clean`** - Not needed, slows down builds
- ✅ Use existing build cache between builds
- ✅ Search output files with grep instead of loading entire contents

## Log Capture: `./claude/scripts/capture-logs` and `./claude/scripts/stop-logs`

### Purpose
Captures app console output (print statements, NSLog, os_log) to timestamped files.

### Typical Workflow

**Step 1: Start log capture**
```bash
./claude/scripts/capture-logs com.example.myapp
```

**Step 2: Launch your app in Xcode** (Cmd+R)
- Your app runs normally
- Logs are captured in background

**Step 3: Interact with the app**
- Reproduce the issue
- Trigger the feature you're testing

**Step 4: Stop log capture**
```bash
./claude/scripts/stop-logs
```

**Step 5: Search the logs**
```bash
grep -i error ./build/logs/logs-*.txt
grep -i "ViewModel" ./build/logs/logs-*.txt
```

### Subsystem Filtering

The `capture-logs` script filters by subsystem/bundle ID to reduce noise.

**Examples:**
```bash
# Capture logs from your app's main subsystem
./claude/scripts/capture-logs com.mycompany.myapp

# Capture logs from a specific subsystem
./claude/scripts/capture-logs com.mycompany.myapp.CoreData

# If you're not sure about the subsystem, use a prefix:
# (Note: simctl's predicate syntax might require exact matches)
./claude/scripts/capture-logs com.example
```

### Output
- ✅ Logs to: `./build/logs/logs-YYYYMMDD-HHMMSS.txt`
- ✅ Stores PID for cleanup
- ✅ Independent of xcodebuild builds

### Stopping Logs

Always stop logs after testing:
```bash
./claude/scripts/stop-logs
```

This kills the background log capture process.

## File Organization

```
./build/
├── xcodebuild/          # Build outputs
│   └── build-*.txt      # One per build
└── logs/                # App logs
    ├── logs-*.txt       # One per capture session
    └── .last-capture-pid # PID of active capture (temporary)
```

## Search Patterns

### Find Build Errors
```bash
grep -i "error:" ./build/xcodebuild/build-*.txt
```

### Find Warnings
```bash
grep -i "warning:" ./build/xcodebuild/build-*.txt
```

### Find Test Failures
```bash
grep -i "failed" ./build/xcodebuild/build-*.txt
```

### Search App Logs
```bash
grep "ViewController" ./build/logs/logs-*.txt
grep -i "crash" ./build/logs/logs-*.txt
grep "ERROR" ./build/logs/logs-*.txt
```

### Count Occurrences
```bash
grep -c "MyClass" ./build/logs/logs-*.txt
```

### Show Context
```bash
grep -C 3 "error" ./build/logs/logs-*.txt  # 3 lines before/after
```

## Workflow Examples

### Debugging App Crash

1. Start logs: `./claude/scripts/capture-logs com.myapp.vision`
2. Launch app: Cmd+R in Xcode
3. Reproduce crash
4. Stop logs: `./claude/scripts/stop-logs`
5. Search: `grep -i "crash\|exception\|error" ./build/logs/logs-*.txt`

### Debugging Build Failures

1. Build: `./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build -destination 'generic/platform=visionOS Simulator'`
2. Search: `grep -i "error" ./build/xcodebuild/build-*.txt`
3. Show context: `grep -C 5 "error" ./build/xcodebuild/build-*.txt`

### Performance Profiling

1. Start logs: `./claude/scripts/capture-logs com.myapp.vision`
2. Launch app: Cmd+R
3. Run performance test
4. Stop logs: `./claude/scripts/stop-logs`
5. Search for performance markers: `grep "duration\|elapsed\|ms" ./build/logs/logs-*.txt`

## Advantages Over XcodeBuildMCP

| Aspect | XcodeBuildMCP | These Scripts |
|--------|---------------|---------------|
| Complexity | 84+ tools, TypeScript server | 3 bash scripts, ~100 lines total |
| Reliability | ❌ Often fails | ✅ Just wraps Apple's tools |
| Token Efficiency | ❌ Large responses | ✅ File-based, search what you need |
| Setup Time | ⏱️ Complex configuration | ⚡ Works immediately |
| Maintenance | 🔧 Requires debugging | 🔒 Stable, no dependencies |
| Features | 🌟 Many tools | 📍 Focused, what you need |

## Key Principles

1. **File-based outputs** - Save to timestamped files, not memory
2. **Search, don't load** - Use grep/head/tail to find what you need
3. **Simple tools** - Bash wrappers, not complex protocols
4. **Independent** - Log capture and builds don't interfere
5. **Reliable** - Built on Apple's battle-tested tools

## Troubleshooting

### Log capture fails with "Invalid simulator"
- Check simulator is running: `xcrun simctl list`
- Use correct simulator ID or "booted" for active simulator
- Example: `./claude/scripts/capture-logs com.myapp.vision booted`

### Logs not appearing
- Verify subsystem name matches your app's logging setup
- Check that your app is actually writing logs with that subsystem
- Try: `./claude/scripts/capture-logs com.myapp.vision` (may capture all)

### xcodebuild wrapper doesn't find workspace
- Verify path: `ls -la XXX.xcworkspace`
- Must be relative to where you run the script
- Example: `./claude/scripts/xcodebuild -workspace ./MyApp.xcworkspace ...`

### Can't find grep results
- Check file exists: `ls -la ./build/logs/ ./build/xcodebuild/`
- Try without wildcards: `grep error ./build/logs/logs-20251020-*.txt`
- Use `-r` for recursive: `grep -r error ./build/`

## Integration with Claude Code

When working with Claude Code:

1. **Ask Claude to run builds:** "Build the visionOS app"
   - Claude will call: `./claude/scripts/xcodebuild ...`
   - Results saved to file
   - Claude reads file with grep

2. **Ask Claude to capture logs:** "Capture logs from my app"
   - Claude will call: `./claude/scripts/capture-logs com.yourapp`
   - Launch app manually in Xcode
   - Ask Claude to read logs after stopping

3. **Ask Claude to analyze:** "Find errors in the build"
   - Claude greps the build output file
   - Shows only relevant errors
   - No token waste from full output

## Next Steps

- Review scripts in `./.claude/scripts/`
- Start with: `./claude/scripts/xcodebuild -h` (for xcodebuild help)
- Try a build: `./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build`
- Test log capture with your app
DOCUMENTATION

echo "   ✅ building-with-xcode.md created"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Installation Complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo -e "${BLUE}📂 Files Created:${NC}"
echo "   ./.claude/scripts/capture-logs"
echo "   ./.claude/scripts/stop-logs"
echo "   ./.claude/scripts/xcodebuild"
echo "   ./.claude/building-with-xcode.md"
echo ""
echo -e "${BLUE}📁 Directories Created:${NC}"
echo "   ./.claude/scripts/"
echo "   ./build/logs/"
echo "   ./build/xcodebuild/"
echo ""
echo -e "${YELLOW}🚀 Quick Start:${NC}"
echo ""
echo "   1. Build your app:"
echo "      ./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build"
echo ""
echo "   2. Capture logs while testing:"
echo "      ./claude/scripts/capture-logs com.yourapp.vision"
echo "      # Launch app in Xcode (Cmd+R)"
echo "      ./claude/scripts/stop-logs"
echo ""
echo "   3. Find errors:"
echo "      grep -i error ./build/xcodebuild/build-*.txt"
echo "      grep -i error ./build/logs/logs-*.txt"
echo ""
echo -e "${BLUE}📖 Documentation:${NC}"
echo "   Read: ./.claude/building-with-xcode.md"
echo ""
echo -e "${GREEN}Happy building! 🎉${NC}"
