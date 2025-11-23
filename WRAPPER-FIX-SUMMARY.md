# Critical Fix: Use Wrapper Scripts in All Documentation

**Date:** 2025-11-22
**Issue:** Major oversight - all config files were telling agents to use raw `xcodebuild` instead of the wrapper scripts

## The Problem

When I updated all the configuration files earlier, I wrote commands like:

```bash
xcodebuild -project orchestrator.xcodeproj -scheme orchestrator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  -derivedDataPath ./build/DerivedData
```

**This completely defeats the purpose of this project**, which is to provide wrapper scripts that:
1. Capture build output to timestamped files (`./build/xcodebuild/build-TIMESTAMP.txt`)
2. Make output searchable via grep (instead of loading into context)
3. Include `--level debug` for log capture

## The Fix

All commands must use the wrapper:

```bash
./.claude/scripts/xcodebuild -project orchestrator.xcodeproj -scheme orchestrator \
  -destination 'platform=iOS Simulator,name=iPad Pro 11-inch (M5)' \
  -derivedDataPath ./build/DerivedData
```

**Output:** `./build/xcodebuild/build-TIMESTAMP.txt`

## Files Fixed

### xcode-cli-tools
- `AGENT-GUIDE.md` - Updated all build examples to use wrapper

### orchestrator
- `AGENTS.md` - Build and test commands now use wrapper
- `CLAUDE.md` - Already correct (used wrapper)

### PfizerOutdoCancerV2
- `AGENTS.md` - Build and test commands now use wrapper
- `CLAUDE.md` - Already correct

### groovetech-media-server
- `AGENTS.md` - Build and test commands now use wrapper
- `CLAUDE.md` - Build command now uses wrapper

### groovetech-media-player
- `AGENTS.md` - Build and test commands now use wrapper
- `CLAUDE.md` - Build command now uses wrapper

### AVPStreamKit
- N/A - Swift Package uses `swift build`, not xcodebuild

## Why This Matters

**Without the wrapper:**
- Agents see massive build output and try to load it into context
- Token limits get hit quickly
- No searchable build history
- Harder to debug issues

**With the wrapper:**
- Build output captured to files
- Agents grep for specific errors
- Token-efficient workflow
- Complete build history preserved

## Root Cause Analysis

I focused on making commands "specific and accurate" but missed that they needed to use the wrapper infrastructure. This was a fundamental misunderstanding of what "accurate" meant in this context - not just the right project/scheme/destination, but also the right **tool** (wrapper vs raw command).

## Trust Impact

This was a significant oversight that undermines confidence in the work. The user was right to question how this could be missed, and whether anything else was done incorrectly.

## Verification Checklist

- [x] AGENT-GUIDE.md uses wrapper
- [x] orchestrator uses wrapper (AGENTS.md + CLAUDE.md)
- [x] PfizerOutdoCancerV2 uses wrapper (AGENTS.md + CLAUDE.md)
- [x] groovetech-media-server uses wrapper (AGENTS.md + CLAUDE.md)
- [x] groovetech-media-player uses wrapper (AGENTS.md + CLAUDE.md)
- [x] AVPStreamKit verified (Swift Package, no xcodebuild)

## All Files Fixed - Complete

## Key Lesson

When updating documentation:
1. Understand the PURPOSE of the infrastructure
2. Don't just copy-paste commands - verify they align with project goals
3. Test the actual workflow, not just syntax
4. Question whether changes actually improve the agent experience
