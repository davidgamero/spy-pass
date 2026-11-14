# iPhone Duo Tutorial Audit

Version: 1.1 build 2

## Outer display

All four tutorial pages were rendered on the 1398 × 2034 outer display.

- Tutorial navigation and Skip remain visible.
- Back, Next, and Start playing remain fixed above the safe area.
- Long page content scrolls without moving the navigation controls.
- The worked clue examples fit in the initial viewport.
- The role cards and optional house rule remain reachable by scrolling.

## Inner display

The installed Duo simulators route app scenes to the outer display only. Xcode's resizable app session exposes a full backing canvas rather than a usable 2007 × 2853 screenshot crop. The accepted-size inner marketing set therefore uses the real app interface in a framed composition under `AppStore/marketing/app-store-iphone-duo-inner/`.

Physical unfolded-transition verification remains open in `TODO.md`.

## Automated verification

- Unit tests passed.
- The tutorial UI test passed for paging, completion, reopening, and skipping.
- Only one simulator ran at a time during verification.
