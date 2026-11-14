# Spy Pass Development Rules

## Required UI preflight before every build

Before running any Xcode build, test, run, archive, install, or launch command, load and apply both project skills:

- `.opencode/skills/impeccable/SKILL.md`
- `.opencode/skills/deslop/SKILL.md`

This requirement applies to `xcodebuild`, Xcode MCP build/run tools, simulator installs, and physical-device installs. Do not start the build until the preflight is complete.

For the Impeccable preflight:

1. Run the skill's context command once per session.
2. Treat Spy Pass as a native iOS **Operate** experience and use the native iOS guidance.
3. Review changed UI for safe areas, Dynamic Type, VoiceOver labels and order, 44 pt touch targets, contrast, Reduce Motion, keyboard behavior, and phone/iPad adaptivity.
4. Preserve the established dark dossier design, player colors, privacy behavior, and game rules.
5. Resolve P0 and P1 UI findings before building. Fix relevant lower-priority findings when they are within the current task.
6. Do not run Impeccable's web detector against SwiftUI files; use its native source and simulator review workflow.

For the Deslop preflight:

1. Review every changed user-facing string.
2. Remove filler, repeated instructions, formulaic contrasts, vague claims, and unnecessary labels.
3. Keep copy direct and specific without changing the game rules or required privacy warnings.
4. Skip prose review only when the pending build contains no user-facing text changes, but still load the skill as required.

## Simulator policy

- Never run more than one simulator at a time.
- Reuse the currently booted simulator when it supports the required check.
- Before booting a simulator, run `xcrun simctl list devices booted` and inspect the exact UDID.
- If a different simulator is booted, shut it down with `xcrun simctl shutdown <UDID>` and confirm it is no longer booted before starting the requested simulator.
- If multiple simulators are already booted, shut down all but the one needed for the task before continuing.
- Use UDIDs rather than display names because simulator names can collide.
- A connected physical device does not count as a simulator, but do not boot a simulator when the physical device is sufficient for the check.

## Build verification

- Build with the `SpyPass` scheme.
- Run unit tests after behavior or model changes.
- Check build warnings as well as errors.
- For UI changes, inspect the rendered app on the one permitted simulator or on the physical device before considering the task complete.
