---
status: resolved
priority: p2
issue_id: "003"
tags: [documentation, clarity, pfizer, cleanup]
dependencies: []
resolved_date: 2025-11-23
---

# Remove Obsolete "Xcode CLI Tools Integration" Section from PfizerOutdoCancerV2 AGENTS.md

## Problem Statement

The AGENTS.md file contains a verbose "Xcode CLI Tools Integration" section (lines 280-329) that was supposed to be removed during the config update. This section provides generic examples that don't match the project-specific commands shown earlier in the file, creating confusion about which commands to use.

## Findings

- **Location**: PfizerOutdoCancerV2/AGENTS.md:280-329
- **Issue Type**: Documentation bloat - obsolete section not removed as intended
- **Impact**: Creates confusion with generic examples that contradict specific commands

### File Structure Issues:
The file currently has:
- **Lines 145-175**: Specific PfizerOutdoCancer build/test commands ✅ (correct)
  ```bash
  ./.claude/scripts/xcodebuild -project PfizerOutdoCancer.xcodeproj -scheme PfizerOutdoCancer \
    -destination 'platform=visionOS Simulator,name=Apple Vision Pro' \
    -derivedDataPath ./build/DerivedData
  ```

- **Lines 280-329**: Generic "Xcode CLI Tools Integration" section ❌ (should be removed)
  - Contains table with generic tasks
  - Has examples with `MyApp` placeholders
  - Shows different destination format
  - Was supposed to be replaced with concise commands

### Problem Scenario:
1. Agent reads specific visionOS commands in "Build, Test, and Development" section (lines 145-175)
2. Scrolls down and finds "Xcode CLI Tools Integration" section
3. Sees different, more generic examples with `MyApp.xcworkspace` and `MyApp` scheme
4. Gets confused about which commands to actually use
5. May use the wrong workspace/project format or miss project-specific details
6. Generic examples show `'generic/platform=visionOS Simulator'` instead of the correct `'platform=visionOS Simulator,name=Apple Vision Pro'`

### Documented Intent:
From CONFIG-UPDATE-SUMMARY.md:
> **3. Removed verbose sections** - Replaced "Xcode CLI Tools Integration" with concise build commands

This section was **supposed to be removed** but was missed during the update.

## Proposed Solutions

### Option 1: Delete Lines 280-329 (RECOMMENDED)
- **Pros**:
  - Eliminates confusion
  - Matches documented intent from CONFIG-UPDATE-SUMMARY
  - File already has complete, specific commands in earlier sections
  - Reduces maintenance burden
- **Cons**: None
- **Effort**: Small (2 minutes)
- **Risk**: None (redundant content)

## Recommended Action

Delete the entire "Xcode CLI Tools Integration" section (lines 280-329) because:
1. It was supposed to be removed per CONFIG-UPDATE-SUMMARY.md
2. The file already has complete, project-specific commands
3. Generic examples create confusion
4. This aligns with the "concise and lean" goal

## Technical Details

- **Affected Files**:
  - PfizerOutdoCancerV2/AGENTS.md (lines 280-329 to be deleted)
- **Related Components**:
  - None - pure documentation cleanup
- **Database Changes**: No

## Resources

- CONFIG-UPDATE-SUMMARY.md - Documents intent to remove this section
- Lines 145-175 in same file - Complete, specific commands that replace this section

## Acceptance Criteria

- [ ] Lines 280-329 "Xcode CLI Tools Integration" section removed
- [ ] Verify file still has complete build/test instructions in earlier sections
- [ ] No broken references to the removed section
- [ ] File remains coherent and complete without the removed content

## Work Log

### 2025-11-22 - Initial Discovery
**By:** Claude Triage System
**Actions:**
- Issue discovered during comprehensive documentation audit
- Categorized as P2 IMPORTANT (affects documentation clarity)
- Estimated effort: Small (2 minutes)

**Learnings:**
- Section removal was documented as complete but not actually done
- This is an example of claiming work was done when it wasn't
- Need to verify all "removed" items are actually removed in future audits

## Notes

Source: Comprehensive triage session requested by user after trust issues with previous wrapper fix
Context: CONFIG-UPDATE-SUMMARY.md claimed this section was removed, but it wasn't
Impact: Lower priority than wrapper issues, but still creates confusion and bloat
