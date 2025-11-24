---
status: resolved
priority: p1
issue_id: "001"
tags: [documentation, consistency, wrapper, pfizer]
dependencies: []
resolved_date: 2025-11-23
---

# Fix PfizerOutdoCancerV2 CLAUDE.md Essential Commands Table

## Problem Statement

The "Essential Commands" table in PfizerOutdoCancerV2/CLAUDE.md contains raw `xcodebuild` commands instead of using the wrapper script `./.claude/scripts/xcodebuild`. This contradicts the entire purpose of the wrapper infrastructure and creates inconsistency with the rest of the documentation.

## Findings

- **Location**: PfizerOutdoCancerV2/CLAUDE.md:113, 115
- **Issue Type**: Documentation inconsistency - raw xcodebuild used instead of wrapper
- **Impact**: Agents following the "Essential Commands" table will bypass the wrapper, defeating the purpose of output capture and token-efficient workflows

### Current State (INCORRECT):
```markdown
| **Build for Simulator** | `xcodebuild -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -derivedDataPath ./build/DerivedData` |
| **Run Tests** | `xcodebuild test -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro'` |
```

### Problem Scenario:
1. Agent reads "Essential Commands" table
2. Copies `xcodebuild -project ...` command (line 113)
3. Runs build without wrapper
4. Build output goes to stdout, not captured to file
5. Agent tries to read massive output, hits token limits
6. No searchable build history created in `./build/xcodebuild/build-*.txt`
7. Debugging becomes difficult without grep-able output

## Proposed Solutions

### Option 1: Fix Table to Use Wrapper (RECOMMENDED)
- **Pros**: Consistent with all other documentation, maintains wrapper benefits
- **Cons**: None
- **Effort**: Small (5 minutes)
- **Risk**: Low

Update lines 113 and 115 to:
```markdown
| **Build for Simulator** | `./.claude/scripts/xcodebuild -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro' -derivedDataPath ./build/DerivedData` |
| **Run Tests** | `./.claude/scripts/xcodebuild test -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer -destination 'platform=visionOS Simulator,name=Apple Vision Pro'` |
```

## Recommended Action

Fix the Essential Commands table to use the wrapper script for consistency with:
- The rest of CLAUDE.md documentation
- AGENTS.md documentation
- AGENT-GUIDE.md in xcode-cli-tools
- The stated purpose of the wrapper infrastructure

## Technical Details

- **Affected Files**:
  - PfizerOutdoCancerV2/CLAUDE.md (lines 113, 115)
- **Related Components**:
  - Wrapper script: `./.claude/scripts/xcodebuild`
  - Build output directory: `./build/xcodebuild/`
- **Database Changes**: No

## Resources

- Wrapper script: `./.claude/scripts/xcodebuild`
- WRAPPER-FIX-SUMMARY.md in xcode-cli-tools repo
- Related issue: This was part of the wrapper fix but the Essential Commands table was missed

## Acceptance Criteria

- [ ] Line 113 "Build for Simulator" command uses `./.claude/scripts/xcodebuild`
- [ ] Line 115 "Run Tests" command uses `./.claude/scripts/xcodebuild`
- [ ] Verify no other table entries in CLAUDE.md use raw xcodebuild
- [ ] Document that output is captured to `./build/xcodebuild/build-TIMESTAMP.txt`

## Work Log

### 2025-11-22 - Initial Discovery
**By:** Claude Triage System
**Actions:**
- Issue discovered during comprehensive documentation audit
- Categorized as P1 CRITICAL (affects core wrapper functionality)
- Estimated effort: Small (5 minutes)

**Learnings:**
- Table-formatted commands were missed during the wrapper fix sweep
- Need to check markdown tables separately from code blocks in future audits
- This is an inconsistency in documentation that was already supposed to be fixed

## Notes

Source: Comprehensive triage session requested by user after trust issues with previous wrapper fix
Context: This table was not updated during the WRAPPER-FIX that claimed to fix all instances
