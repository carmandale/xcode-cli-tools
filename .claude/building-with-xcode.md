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
