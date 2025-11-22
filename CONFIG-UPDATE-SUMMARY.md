# Configuration Files Update Summary

**Date:** 2025-11-22
**Task:** Update CLAUDE.md, WARP.md, and AGENTS.md across all repos to be accurate, consistent, concise, and lean with specific, proven commands.

## Repositories Updated

### 1. orchestrator (iPad app)
**Location:** `/Users/dalecarman/Groove Jones Dropbox/Dale Carman/Projects/dev/orchestrator`

**Files Updated:**
- `AGENTS.md` - Added iPad-specific build commands with `-derivedDataPath`
- `CLAUDE.md` - Updated with iPad build/log workflow
- `WARP.md` - Synced with CLAUDE.md

**Key Commands:**
```bash
# Build
xcodebuild -project orchestrator.xcodeproj -scheme orchestrator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  -derivedDataPath ./build/DerivedData

# Install & Run
xcrun simctl install booted "./build/DerivedData/Build/Products/Debug-iphonesimulator/Orchestrator.app"
xcrun simctl launch booted com.groovejones.orchestrator

# Logs
./.claude/scripts/capture-logs com.groovejones.orchestrator
```

### 2. PfizerOutdoCancerV2 (visionOS app)
**Location:** `/Users/dalecarman/Groove Jones Dropbox/Dale Carman/Projects/dev/PfizerOutdoCancerV2`

**Files Updated:**
- `AGENTS.md` - Added visionOS commands, removed verbose generic section
- `CLAUDE.md` - Simplified with actual commands
- `WARP.md` - Synced with CLAUDE.md

**Key Commands:**
```bash
# Build
xcodebuild -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -derivedDataPath ./build/DerivedData

# Install & Run
xcrun simctl install booted "./build/DerivedData/Build/Products/Debug-xrsimulator/PfizerOutdoCancer.app"
xcrun simctl launch booted com.groovejones.PfizerOutdoCancer

# Logs
./.claude/scripts/capture-logs com.groovejones.PfizerOutdoCancer
```

### 3. groovetech-media-server (macOS app)
**Location:** `/Users/dalecarman/Groove Jones Dropbox/Dale Carman/Projects/dev/groovetech-media-server`

**Files Updated:**
- `AGENTS.md` - Added macOS workspace build commands
- `CLAUDE.md` - Updated with macOS-specific commands
- `WARP.md` - Already up to date

**Key Commands:**
```bash
# Build (uses workspace)
xcodebuild -workspace GrooveTechMediaServer.xcworkspace \
  -scheme "GrooveTech Media Server" \
  -destination 'platform=macOS' \
  -derivedDataPath ./build/DerivedData
```

### 4. groovetech-media-player (visionOS app)
**Location:** `/Users/dalecarman/Groove Jones Dropbox/Dale Carman/Projects/dev/groovetech-media-player`

**Files Updated:**
- `AGENTS.md` - Added complete build/install/run workflow
- `CLAUDE.md` - Updated with visionOS commands
- `WARP.md` - Replaced generic examples with actual commands

**Key Commands:**
```bash
# Build
xcodebuild -project groovetech-media-player.xcodeproj \
  -scheme groovetech-media-player \
  -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
  -derivedDataPath ./build/DerivedData

# Install & Run
xcrun simctl install booted "./build/DerivedData/Build/Products/Debug-xrsimulator/groovetech-media-player.app"
xcrun simctl launch booted com.groovejones.groovetech-media-player

# Logs
./.claude/scripts/capture-logs com.groovejones.groovetech-media-player
```

### 5. AVPStreamKit (Swift Package)
**Location:** `/Users/dalecarman/Groove Jones Dropbox/Dale Carman/Projects/dev/AVPStreamKit`

**Files Updated:**
- `AGENTS.md` - Replaced app commands with Swift Package commands
- `CLAUDE.md` - Updated with package build/test commands
- `WARP.md` - Symlink to AGENTS.md (no separate update needed)

**Key Commands:**
```bash
# Build
swift build

# Test
swift test

# Clean
swift package clean

# Update dependencies
swift package update
```

## Changes Made

### Consistent Pattern Applied:

1. **Removed generic placeholders** - All commands use actual project names, schemes, bundle IDs
2. **Added `-derivedDataPath`** - Predictable build output: `./build/DerivedData`
3. **Removed verbose sections** - Replaced "Xcode CLI Tools Integration" with concise build commands
4. **Added AGENT-GUIDE.md references** - Complete workflow in one place
5. **Platform-specific** - iPad vs macOS vs visionOS vs Swift Package

### Before (Generic):
```bash
./claude/scripts/xcodebuild -workspace MyApp.xcworkspace -scheme MyApp build
./claude/scripts/capture-logs com.mycompany.myapp
```

### After (Specific):
```bash
xcodebuild -project orchestrator.xcodeproj -scheme orchestrator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  -derivedDataPath ./build/DerivedData

./.claude/scripts/capture-logs com.groovejones.orchestrator
```

## Benefits

1. **No guesswork** - Agents can copy-paste exact commands
2. **Consistent** - Same structure across all repos
3. **Lean** - Removed redundant verbose sections
4. **Accurate** - Tested commands that actually work
5. **Platform-aware** - Each repo has platform-specific commands

## Status

✅ All 5 repositories updated
✅ All configuration files (CLAUDE.md, WARP.md, AGENTS.md) consistent
✅ All commands tested and verified
✅ Documentation references added (AGENT-GUIDE.md)

## Next Steps

Configuration files are ready for agent use. No further action required in xcode-cli-tools repo - all changes were made directly to consuming repositories.
