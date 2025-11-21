# Agent Guide: Building and Capturing Useful Logs

**Quick reference for AI agents working with Xcode projects**

## Critical Success Factors

### ✅ DO THIS
1. **Always capture logs with the wrapper scripts** - They include `--level debug` to capture useful diagnostic information
2. **Use the build wrapper** - It captures output to searchable files
3. **Search logs with grep** - Don't load entire log files into context
4. **Wait for app to run** - Logs only capture when the app is actually running

### ❌ DON'T DO THIS
1. **Never use `xcodebuild -clean`** - It's unnecessary and slows builds
2. **Never capture logs without starting the app** - You'll get empty files
3. **Never load entire build/log files** - Use grep to find what you need
4. **Never assume the simulator** - Verify it's running with `xcrun simctl list`

## Build Command Template

```bash
./claude/scripts/xcodebuild \
  -project ../orchestrator/orchestrator.xcodeproj \
  -scheme orchestrator \
  build \
  -destination 'generic/platform=iOS Simulator'
```

**For other platforms:**
- iPad/iPhone Simulator: `-destination 'generic/platform=iOS Simulator'`
- iPad/iPhone Device: `-destination generic/platform=iOS`
- visionOS Simulator: `-destination 'generic/platform=visionOS Simulator'`
- visionOS Device: `-destination generic/platform=visionOS`

## Log Capture Workflow

**IMPORTANT: The scripts now include `--level debug` automatically - this captures useful logs!**

### Step 1: Start capture BEFORE running the app
```bash
./claude/scripts/capture-logs com.example.appname
```

### Step 2: Launch the app in Xcode
```bash
# User runs: Cmd+R in Xcode
# OR build and run via command line
```

### Step 3: Use the app / reproduce the issue
```bash
# Let the app run and generate logs
# Reproduce the bug or test the feature
```

### Step 4: Stop capture
```bash
./claude/scripts/stop-logs
```

### Step 5: Search for useful information
```bash
# Find errors
grep -i error ./build/logs/logs-*.txt

# Find specific classes/methods
grep "MyViewController" ./build/logs/logs-*.txt

# Show context (3 lines before/after)
grep -C 3 "ERROR" ./build/logs/logs-*.txt
```

## Why Logs Were Empty Before

**The Problem:** The script was missing `--level debug` flag, so it only captured Info and Error level logs. Most useful debug statements (`Logger.debug()`, `print()`, detailed diagnostics) are at Debug level.

**The Fix:** Now includes:
```bash
xcrun simctl spawn booted log stream --level debug --style compact --predicate "subsystem == 'com.example.app'"
```

## Common Issues and Solutions

### Issue: Empty or tiny log files
**Cause:** App not running, or wrong subsystem name
**Solution:**
1. Verify app is running in simulator
2. Check subsystem name matches your app's logging setup
3. Try broader predicate: `com.example` instead of `com.example.app.specific`

### Issue: Build fails with "no scheme"
**Cause:** Wrong project path or scheme name
**Solution:**
1. Run `cd ../orchestrator && xcodebuild -list` to see available schemes
2. Use exact scheme name from the output

### Issue: Simulator not found
**Cause:** Simulator not booted
**Solution:**
1. Check: `xcrun simctl list | grep Booted`
2. Boot simulator in Xcode or use specific simulator ID

## File Locations

```
./build/
├── xcodebuild/
│   └── build-20251121-143022.txt    # Build output with timestamp
└── logs/
    └── logs-20251121-143500.txt     # App logs with timestamp
```

## Search Patterns for Troubleshooting

```bash
# Build errors
grep -i "error:" ./build/xcodebuild/build-*.txt

# Build warnings
grep -i "warning:" ./build/xcodebuild/build-*.txt

# Test failures
grep -i "failed" ./build/xcodebuild/build-*.txt

# Runtime crashes
grep -i "crash\|exception\|fatal" ./build/logs/logs-*.txt

# Specific class/function
grep -C 5 "MyClass" ./build/logs/logs-*.txt

# Count occurrences
grep -c "ERROR" ./build/logs/logs-*.txt
```

## Token-Efficient Workflow

Instead of loading entire files:

```bash
# ❌ DON'T: Load entire 50MB build log
cat ./build/xcodebuild/build-latest.txt

# ✅ DO: Search for what you need
grep -i error ./build/xcodebuild/build-*.txt
```

## Quick Checklist

Before claiming "logs are useless" or "build failed mysteriously":

- [ ] Used the wrapper scripts (not raw xcodebuild/simctl)
- [ ] Started log capture BEFORE launching app
- [ ] Verified app actually ran (not just built)
- [ ] Used grep to search logs (not cat to dump everything)
- [ ] Checked the correct timestamp file (most recent)
- [ ] Searched for relevant keywords (class names, error types)

## For More Details

See `building-with-xcode.md` for complete documentation including:
- Advanced grep patterns
- Platform-specific builds
- Performance profiling
- Integration with Claude Code

---

**Last Updated:** 2025-11-21 (Added --level debug fix)
