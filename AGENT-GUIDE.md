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

## Complete Build, Install, and Log Workflow

This is the VERIFIED working workflow. Follow these steps exactly.

### Step 1: Build the App

**CRITICAL:** Use the `./.claude/scripts/xcodebuild` wrapper to capture build output to searchable files. Always include `-derivedDataPath` to make the `.app` file location predictable.

```bash
cd /path/to/your/project

# For Simulator (iPad/iPhone)
./.claude/scripts/xcodebuild \
  -project orchestrator.xcodeproj \
  -scheme orchestrator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  -derivedDataPath ./build/DerivedData

# For Simulator (visionOS)
./.claude/scripts/xcodebuild \
  -project YourApp.xcodeproj \
  -scheme YourApp \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -derivedDataPath ./build/DerivedData

# For Device (iPad/iPhone)
./.claude/scripts/xcodebuild \
  -project orchestrator.xcodeproj \
  -scheme orchestrator \
  -destination 'generic/platform=iOS' \
  -derivedDataPath ./build/DerivedData

# For Device (visionOS)
./.claude/scripts/xcodebuild \
  -project YourApp.xcodeproj \
  -scheme YourApp \
  -destination 'generic/platform=visionOS' \
  -derivedDataPath ./build/DerivedData
```

**The wrapper captures output to:** `./build/xcodebuild/build-TIMESTAMP.txt`

**Expected output:** `** BUILD SUCCEEDED **`

**Built app location (Simulator):**
- iOS: `./build/DerivedData/Build/Products/Debug-iphonesimulator/YourApp.app`
- visionOS: `./build/DerivedData/Build/Products/Debug-xrsimulator/YourApp.app`

**Built app location (Device):**
- iOS: `./build/DerivedData/Build/Products/Debug-iphoneos/YourApp.app`
- visionOS: `./build/DerivedData/Build/Products/Debug-xros/YourApp.app`

**IMPORTANT:** The `.app` name uses the product name (often capitalized), not the scheme name:
- Scheme: `orchestrator` → Product: `Orchestrator.app`

**If build fails, search the output:**
```bash
# Find the most recent build output
LAST_BUILD=$(ls -t ./build/xcodebuild/build-*.txt | head -n 1)

# Search for errors
grep -i "error:" "$LAST_BUILD"

# Search with context (3 lines before/after)
grep -C 3 -i "error:" "$LAST_BUILD"
```

### Step 2: Install the App (Simulator Only)

```bash
# Install on booted simulator
xcrun simctl install booted \
  "./build/DerivedData/Build/Products/Debug-iphonesimulator/Orchestrator.app"

# For visionOS
xcrun simctl install booted \
  "./build/DerivedData/Build/Products/Debug-xrsimulator/YourApp.app"
```

**Expected:** Silent success (no output)

**Verify installation:**
```bash
xcrun simctl list apps booted | grep -i orchestrator
```

### Step 3: Start Log Capture

**For Simulator:**
```bash
./.claude/scripts/capture-logs com.groovejones.orchestrator
```

**For Device:**
```bash
# Device logging uses a different command (see device section below)
xcrun devicectl device info logs stream \
  --device <device-id> \
  --style compact \
  --predicate 'subsystem == "com.groovejones.orchestrator"' \
  > ./build/logs/logs-device-$(date +%Y%m%d-%H%M%S).txt &

# Save PID for cleanup
echo $! > ./build/logs/.last-device-capture-pid
```

### Step 4: Launch the App

**For Simulator:**
```bash
xcrun simctl launch booted com.groovejones.orchestrator
```

**Expected:** `com.groovejones.orchestrator: 56532` (PID number)

**For Device:**
```bash
# Launch via Xcode (Cmd+R) or:
xcrun devicectl device process launch \
  --device <device-id> \
  com.groovejones.orchestrator
```

### Step 5: Wait for Logs (CRITICAL!)

**DO NOT skip this step!** The app needs time to initialize and emit logs.

```bash
sleep 10
```

Interact with the app if needed to trigger the behavior you're debugging.

### Step 6: Stop Log Capture

**For Simulator:**
```bash
./.claude/scripts/stop-logs
```

**For Device:**
```bash
# Kill the background log process
kill $(cat ./build/logs/.last-device-capture-pid)
rm ./build/logs/.last-device-capture-pid
```

### Step 7: Verify and Search Logs

```bash
# Check file size (should be > 500 bytes if logs captured)
ls -lh ./build/logs/logs-*.txt

# View recent logs
tail -50 ./build/logs/logs-*.txt

# Search for errors
grep -i error ./build/logs/logs-*.txt

# Search with context
grep -C 3 "stream_state_changed" ./build/logs/logs-*.txt
```

**Expected content example:**
```
2025-11-21 18:21:09.946 I  Orchestrator[56532:1ceff69] [com.groovejones.orchestrator:streaming] [Orchestrator] [Streaming] stream_receiver_listening | category=streaming component=AppUIModel port=22345
```

## Device Logging (Physical Devices)

**VERIFIED:** Device logging uses the regular `log stream` command (not simctl or devicectl). When a device is connected via USB, `log stream` automatically captures from it.

### Requirements

1. Device connected via USB
2. Device in Developer Mode
3. Device trusted on this Mac

### Verify Device Connection

```bash
xcrun devicectl list devices
```

Look for your device with status "connected" or "available (paired)".

### Capture Logs on Device

**Method 1: Manual (works now)**

```bash
cd /path/to/your/project

# Start log capture from connected device
xcrun log stream \
  --level debug \
  --style compact \
  --predicate 'subsystem == "com.groovejones.orchestrator"' \
  > ./build/logs/logs-device-$(date +%Y%m%d-%H%M%S).txt 2>&1 &

# Save the PID manually
DEVICE_LOG_PID=$!
echo $DEVICE_LOG_PID > ./build/logs/.last-device-capture-pid

# Launch your app via Xcode (Cmd+R targeting the device)

# Wait for logs to accumulate
sleep 10

# Stop capture
kill $(cat ./build/logs/.last-device-capture-pid)
rm ./build/logs/.last-device-capture-pid

# View logs
tail -50 ./build/logs/logs-device-*.txt
```

**Method 2: Using wrapper script (if available)**

The `capture-logs` script is designed for simulators. For devices, use the manual method above until we create a device-specific wrapper.

### Key Differences from Simulator Logging

| Aspect | Simulator | Physical Device |
|--------|-----------|-----------------|
| Command | `xcrun simctl spawn booted log stream` | `xcrun log stream` |
| Device selection | `--simulator <id>` or `booted` | Automatic (connected device) |
| Multiple devices | Specify simulator ID | May capture from multiple connected devices |
| Requires | Simulator booted | Device connected via USB |

### Tips for Device Logging

1. **Single device:** If you have multiple devices connected, disconnect extras to avoid mixed logs
2. **Process filter:** Add `--process Orchestrator` to filter by process name
3. **Wi-Fi devices:** Device must be on same network and paired for wireless debugging
4. **Check logs are from device:** Look for device name in log output headers

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
