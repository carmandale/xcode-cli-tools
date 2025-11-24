---
status: resolved
priority: p1
issue_id: "002"
tags: [documentation, consistency, wrapper, pfizer, warp]
dependencies: []
resolved_date: 2025-11-23
---

# Fix PfizerOutdoCancerV2 WARP.md Essential Commands Table

## Problem Statement

The WARP.md file contains a Quick Start section with an Essential Commands table that uses raw `xcodebuild` instead of the wrapper script `./.claude/scripts/xcodebuild`. This creates the same inconsistency as CLAUDE.md and defeats the wrapper's purpose.

## Findings

- **Location**: PfizerOutdoCancerV2/WARP.md:48, 50
- **Issue Type**: Documentation inconsistency - raw xcodebuild used instead of wrapper
- **Impact**: WARP AI agents following the Essential Commands table will bypass the wrapper
- **Internal Inconsistency**: Same file uses wrapper correctly in line 58 (troubleshooting table)

### Current State (INCORRECT):
```markdown
| **Build for Simulator** | `xcodebuild -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -derivedDataPath ./build/DerivedData` |
| **Run Tests** | `xcodebuild test -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro'` |
```

### Correct Usage Elsewhere in Same File:
Line 58 correctly uses wrapper:
```markdown
| **List Available Destinations** | `./.claude/scripts/xcodebuild -scheme PfizerOutdoCancer -showdestinations` |
```

### Problem Scenario:
1. WARP user (another AI agent) reads Essential Commands table
2. Copies `xcodebuild -project ...` command from line 48
3. Runs build without wrapper
4. No output capture occurs to `./build/xcodebuild/build-*.txt`
5. Build history not preserved in searchable files
6. Token limits hit when trying to process raw stdout output

## Proposed Solutions

### Option 1: Fix Table to Use Wrapper (RECOMMENDED)
- **Pros**: Consistent with wrapper usage elsewhere in same file and across all docs
- **Cons**: None
- **Effort**: Small (5 minutes)
- **Risk**: Low

Update lines 48 and 50 to:
```markdown
| **Build for Simulator** | `./.claude/scripts/xcodebuild -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -derivedDataPath ./build/DerivedData` |
| **Run Tests** | `./.claude/scripts/xcodebuild test -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro'` |
```

## Recommended Action

Fix the Essential Commands table to use the wrapper script for:
- Consistency with line 58 in the same file
- Consistency with CLAUDE.md (after fix)
- Consistency with AGENTS.md
- Proper output capture functionality

## Technical Details

- **Affected Files**:
  - PfizerOutdoCancerV2/WARP.md (lines 48, 50)
- **Related Components**:
  - Wrapper script: `./.claude/scripts/xcodebuild`
  - Build output directory: `./build/xcodebuild/`
- **Database Changes**: No

## Resources

- Wrapper script: `./.claude/scripts/xcodebuild`
- Related issue: #001 (same issue in CLAUDE.md)
- WRAPPER-FIX-SUMMARY.md in xcode-cli-tools repo

## Acceptance Criteria

- [ ] Line 48 "Build for Simulator" command uses `./.claude/scripts/xcodebuild`
- [ ] Line 50 "Run Tests" command uses `./.claude/scripts/xcodebuild`
- [ ] Verify consistency with line 58 which already uses wrapper correctly
- [ ] Document that output is captured to `./build/xcodebuild/build-TIMESTAMP.txt`

## Work Log

### 2025-11-22 - Initial Discovery
**By:** Claude Triage System
**Actions:**
- Issue discovered during comprehensive documentation audit
- Categorized as P1 CRITICAL (affects core wrapper functionality)
- Estimated effort: Small (5 minutes)

**Learnings:**
- WARP.md is a separate file (not symlink) with its own inconsistency
- Same file has both correct (line 58) and incorrect (lines 48, 50) wrapper usage
- Table-formatted commands were missed during the wrapper fix sweep

## Notes

Source: Comprehensive triage session requested by user after trust issues with previous wrapper fix
Context: Part of same pattern as CLAUDE.md - markdown tables were not updated during WRAPPER-FIX
Related: Issue #001
