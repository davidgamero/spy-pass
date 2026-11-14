# iPhone Duo Front-Screen UI Audit

Audit date: November 14, 2026

Target display: iPhone Duo front display, 1398 × 2034 pixels

## Captured states

1. Empty setup
2. Setup with five names
3. Hidden player card
4. Revealed secret name
5. Spy role
6. Discussion
7. Revealed answer

## Results

- Setup keeps the input and Deal button visible while the names list scrolls.
- Long setup guidance wraps without clipping.
- Hidden and revealed cards retain a 4:5 ratio and fit the compact display.
- The hidden-card screen shows the card, reveal button, and privacy reminder in one viewport.
- Secret names wrap and scale inside the card.
- The discussion screen keeps Reveal the answer visible. Secondary round actions remain available by scrolling.
- Revealing the answer scrolls the answer panel into view automatically.
- All primary controls retain at least a 44-point touch target.
- Content stays clear of the front display's status area and home indicator.

## Changes made during the audit

- Added height-aware card sizing for compact displays.
- Replaced flexible card sizing with explicit 4:5 dimensions to prevent distortion.
- Added automatic scrolling when the answer panel appears.
- Added Debug-only mock states for empty setup and revealed answer.

## Verification

- The Duo simulator rendered all seven states on display 1.
- The Duo runtime could not launch XCTest after its inner display was powered off, so the display was restored and the UI audit ran with both panels powered.
- Unit tests passed on the iPhone 18 Pro simulator after the Duo audit.
- Simulators were run one at a time and are now shut down.
