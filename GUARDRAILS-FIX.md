# Worktree Build Guardrails Removal

**Date:** 2025-11-22
**Issue:** Overly restrictive build location guardrails blocking normal operations

## Problem

Added incorrect "Worktree build guardrails" to PfizerOutdoCancerV2/AGENTS.md that prevented agents from building outside of worktree directories:

```markdown
### Worktree build guardrails (AI-only)
- **Always build from the active worktree.** If `pwd` does not include `.worktrees/<branch>`, stop—you're about to compile `main`.
- **Confirm the branch** with `git branch --show-current`; it must match the feature branch.
```

This blocked legitimate use cases like:
- Building from main branch for testing
- Building from non-worktree feature branches
- Quick builds during development

## Root Cause

Misunderstood the worktree workflow as a hard requirement rather than a recommended process for feature development. The worktree workflow is about **organization and safety**, not about enforcing where builds can run.

## Fix

**Removed from:**
- `PfizerOutdoCancerV2/AGENTS.md` (lines 176-178)

**Verified clean in:**
- `orchestrator/AGENTS.md` ✅
- `groovetech-media-player/AGENTS.md` ✅
- `groovetech-media-server/AGENTS.md` ✅
- `AVPStreamKit/AGENTS.md` ✅
- `xcode-cli-tools/AGENT-GUIDE.md` ✅
- `xcode-cli-tools/building-with-xcode.md` ✅

## Correct Approach

### Worktree Workflow (Recommended for Feature Development)
The worktree workflow is a **recommended process** described in the "Worktree Workflow for Feature Development" section:
- Helps keep main clean
- Isolates feature work
- Enables parallel development
- Reduces context switching

### Build Flexibility (Required)
Agents MUST be able to build from:
- Main branch (for testing, verification)
- Feature branches (standard git workflow)
- Worktree branches (recommended workflow)
- Any working directory (for flexibility)

## Key Principle

**The worktree workflow is about PROCESS, not PERMISSION.**

Agents should follow the worktree workflow for feature development, but they must not be blocked from building anywhere when needed.
