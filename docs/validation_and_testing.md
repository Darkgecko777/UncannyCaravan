# Validation & Error Scanning for Uncanny Caravan

## Headless Godot Validation (Recommended before every commit)

From the project root:

```bash
# Basic syntax + project load check (fast)
godot --headless --check-only --path .

# Full editor run with output (shows autoload init, script errors, etc.)
godot --headless --path . --quit 2>&1 | cat
```

If Godot is not in PATH on your machine, use the full path to `Godot.exe` (or `Godot.app` on macOS).

Common locations on Windows:
- `C:\Program Files\Godot\Godot.exe`
- `%LOCALAPPDATA%\Programs\Godot\Godot.exe`
- Steam library Godot installs

## Automated Review Process

We use a dedicated reviewer subagent (general-purpose + strong Godot persona) for every major phase advance:

1. Spawn the subagent with a focused prompt targeting the changed files + Phase readiness.
2. The subagent reads every file, traces data flows, and produces a structured report with severity + concrete fixes.
3. All Critical/High issues must be fixed before the next feature commit.
4. The review output lives in the conversation history for traceability.

Latest full review (Phase 0 post-implementation):
- Performed by general-purpose subagent "error-scanner"
- Identified 6 Critical runtime bugs + many best-practice and Phase 1 blocker issues
- All Critical items addressed in the "fix: Critical Phase 0 bugs" commit + follow-ups

## Current Known Limitations (as of latest commit)

- Only 5/10 goods and 2/5 cities have full .tres definitions (rest coming in next Phase 1 slice)
- Caravan resolution is still stub (real events + proper profit calc = Phase 2)
- No real UI panels yet (debug UI only)
- No RouteData yet

Run the headless check locally after pulling to confirm your Godot version is happy with the project settings.

## Quick Smoke Test (in-editor)

1. F5
2. Click "Add Test Goods" + "Send Test Caravan (stub)"
3. Watch inventory decrease and a caravan appear
4. Wait ~5 seconds or click "Resolve Now"
5. Close window (auto-save)
6. Reopen project → verify inventory, cash, and any caravans are correct (this was one of the Critical bugs fixed)

If the above works cleanly after a quit/relaunch, the save + economy persistence layer is healthy.
